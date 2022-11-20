//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Firebase
import Foundation
import UIKit
protocol FoodListPresenterOutput: AnyObject {
    func update()
//    func didRefreshSwipe()
    func isAppearingTrashBox(isDelete: Bool)
    func present(inputView: FoodAppendViewController?)
    func presentAlert(alert: UIAlertController)
    func dismiss()
    func performSegue(foodNameTextLabel: String?)
    func setTitle(refigerator: Bool, freezer: Bool, selectedKinds: [Food.FoodKind], location: Food.Location)
    func isHidingButtons(isDelete: Bool)
    func animateButton(isFilteringRef: Bool, isFilteringFreezer: Bool)
    func resetButtonColor()
}

final class FoodListPresenter {
    private let foodData: FoodData
    private weak var foodListPresenterOutput: FoodListPresenterOutput?
    //    private let foodUseCase = FoodUseCase.shared
    private(set) var array: [Food] = []
//    private var filteredArray: [Food] = []
    private(set) var isDelete = true
    private(set) var checkedID: [String: Bool] = [:]
    //    private let sharedFoodUseCase = FoodUseCase.shared
    private var didTapCheckBox: ((Bool) -> Void)?
    private(set) static var isTapRow = false
    // static foodUseCaseを消す
    private let foodUseCase: FoodUseCase
    private let db = Firestore.firestore()
    // scrollView読み込み
    private var fetchingNext = false

    init(foodData: FoodData, foodUseCase: FoodUseCase) {
        self.foodData = foodData
        self.foodUseCase = foodUseCase
    }

    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }

    func didLoadView() {
        loadArray()
        foodListPresenterOutput?.update()
    }

    func willViewAppear() {
//        foodListPresenterOutput?.didRefreshSwipe()
        foodListPresenterOutput?.update()
    }
    func didViewAppear() {
        self.foodData.fetch { result in
            switch result {
            case let .success(foods):
                self.array = foods
                self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                self.foodListPresenterOutput?.update()
            case let .failure(error):
                print(error)
                // Alart表示
            }
        }
    }

    func loadArray() {
//        self.foodData.fetch { result in
        self.foodData.fetch { result in
            switch result {
            case let .success(foods):
                self.array = foods
                self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                self.foodListPresenterOutput?.update()
            case let .failure(error):
                print(error)
                // Alart表示
            }
        }
    }
    func didScrollToLast(row: Int) { // scrollView:UIScrollView ,
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        if offsetY > contentHeight - scrollView.frame.height - 50{
        if row == self.array.count - 1 && foodData.countOfDocuments != 0 {
                foodData.paginate()
                foodData.paginatingfetch { result in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        switch result {
                        case let .success(foods):
                            self.array.append(contentsOf: foods)
                            self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                            //                        self.array.sorted(by: <#T##(Food, Food) throws -> Bool#>)
                            // ここに入れることで起動時に表示
                            self.foodListPresenterOutput?.update()
                        case let .failure(error):
                            print(error)
                        }
                    }
                }
            }
//        else if row == self.array.count - 1 {
//                print(row)
//            }
//        }
    }
    func didTapDeleteButton() {
        isDelete.toggle()
        // 削除事に配列を元に戻す
//        foodUseCase.isFilteringFreezer = false
//        foodUseCase.isFilteringRefrigerator = false
//        foodUseCase.selectedKinds = []
        // ボタンの無効化
        foodListPresenterOutput?.isHidingButtons(isDelete: isDelete)
        //
        foodListPresenterOutput?.isAppearingTrashBox(isDelete: isDelete)
        if isDelete, checkedID.values.contains(true) {
            // 削除するかどうかアラート
            let alert = UIAlertController(title: "削除しますか?", message: "", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "はい", style: .default, handler: { _ in
                //                 filterで値のみを取り出し、defoはTrueを取り出すため
                let filteredIDictionary = self.checkedID.filter(\.value).map(\.key)
                self.foodData.delete(filteredIDictionary) { result in
                    switch result {
                    case .success:
                        // ここから
                        self.checkedID = [:]
                        self.foodData.fetch { result in
                            switch result {
                            case let .success(foods):
                                self.array = foods
                                self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                                // このReloadにより削除がtableに反映
                                self.foodListPresenterOutput?.update()
                            case let .failure(error):
                                print("fetchfoodsに失敗:\(error)")
                            }
                            // 下記reloadがないと表示が反映されず1
                            self.foodListPresenterOutput?.update()
                        }
                    case let .failure(error):
                        print("deleteに失敗:\(error)")
                    }
                }
                self.foodListPresenterOutput?.update()
            }))
            alert.addAction(.init(title: "いいえ", style: .destructive, handler: { _ in
                self.checkedID = [:]
                print("削除をキャンセル")
            }))
            foodListPresenterOutput?.presentAlert(alert: alert)
        }
        foodListPresenterOutput?.update()
    }

    // 冷蔵ボタン
    func didTapRefrigiratorButton(_: UIButton) {
        foodUseCase.didTapRefrigeratorButton()
        // ボタンの色を変更
        foodListPresenterOutput?.animateButton(isFilteringRef: foodUseCase.isFilteringRefrigerator, isFilteringFreezer: foodUseCase.isFilteringFreezer)
        didSwitchLocation(location: .refrigerator)
    }

    // 冷凍ボタン
    func didTapFreezerButton(_: UIButton) {
        foodUseCase.didTapFreezerButton()
        foodListPresenterOutput?.animateButton(isFilteringRef: foodUseCase.isFilteringRefrigerator, isFilteringFreezer: foodUseCase.isFilteringFreezer)
        didSwitchLocation(location: .freezer)
    }

    // 冷蔵冷凍ボタンを押した際実行する
    func didSwitchLocation(location: Food.Location) {
        foodUseCase.foodFilter.location = location
        foodUseCase.resetKinds()
        // タイトル編集
        foodListPresenterOutput?.setTitle(
            refigerator: foodUseCase.isFilteringRefrigerator,
            freezer: foodUseCase.isFilteringFreezer,
            selectedKinds: foodUseCase.selectedKinds,
            location: foodUseCase.foodFilter.location
        )
        foodListPresenterOutput?.update()
    }
    // 食材ボタン
    func didTapFoodKindButtons(kind: Food.FoodKind) {

        foodUseCase.toggleDictionary(kind: kind)
        let selectedDictionary = foodUseCase.foodKindDictionary.filter { $0.value == true }
        var selectedFoodKinds = selectedDictionary.map(\.key)
        foodUseCase.foodFilter.kindArray = selectedFoodKinds
        // ここで入る
        foodUseCase.isAddingKinds(selectedKinds: &selectedFoodKinds)
        foodListPresenterOutput?.update()
    }

    // 食材を選択した状態で冷蔵冷凍ボタンを押した際に
    private func refreshFoodKindDictionary() {
        foodUseCase.resetDictionary()
        foodUseCase.foodFilter.kindArray = Food.FoodKind.allCases
        self.foodListPresenterOutput?.resetButtonColor()
    }

    func isTapCheckboxButton(row: Int) -> ((Bool) -> Void)? {
        //        // UUIDをDictionaryに追加
        didTapCheckBox = { isChecked in
            if !self.foodUseCase.isFilteringFreezer,
               !self.foodUseCase.isFilteringRefrigerator,
               self.foodUseCase.selectedKinds.isEmpty {
                self.checkedID[self.array[row].IDkey] = isChecked
            } else {
                self.checkedID[self.configure()[row].IDkey] = isChecked
            }
        }
        return didTapCheckBox
    }
    // 上記食材ボタン,冷凍冷蔵ボタンによる配列への操作を下記に集約させる
    private func configure() -> [Food] {
        var filteredArray = self.array
        if (foodUseCase.isFilteringRefrigerator || foodUseCase.isFilteringFreezer) &&
            !foodUseCase.foodFilter.kindArray.isEmpty {
            // 1
            filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }.filter { foodUseCase.foodFilter.kindArray.contains($0.kind) }
        } else if (foodUseCase.isFilteringRefrigerator || foodUseCase.isFilteringFreezer) &&
                    foodUseCase.foodFilter.kindArray.isEmpty {
            // 2
            filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }
        } else if (!foodUseCase.isFilteringRefrigerator && !foodUseCase.isFilteringFreezer) && !foodUseCase.foodFilter.kindArray.isEmpty {
            // 3
            filteredArray = array.filter { foodUseCase.foodFilter.kindArray.contains($0.kind) }
        }
        return filteredArray
    }

    func isManagingArray(row: Int) -> Food? {
        if !foodUseCase.isFilteringFreezer && !foodUseCase.isFilteringRefrigerator && foodUseCase.selectedKinds.isEmpty {
            return foodInRow(forRow: row)
        } else {
            return filteredFoodInRow(forRow: row)
        }
    }

    private func foodInRow(forRow row: Int) -> Food? {
        // 配列をリフレッシュ
//        self.refreshFoodKindDictionary()
        guard row < array.count else { return nil }
        self.refreshFoodKindDictionary()
        return array[row]
    }

    private func filteredFoodInRow(forRow row: Int) -> Food? { // foodUseCase.selectedKinds.isEmpty
        guard row < array.count else { return nil }
        return self.configure()[row]
    }

    func numberOfRows() -> Int {
        if !foodUseCase.isFilteringFreezer,
           !foodUseCase.isFilteringRefrigerator,
           foodUseCase.selectedKinds.isEmpty {
            return array.count
        } else {
            return self.configure().count
        }
    }

    func didSelectRow(storyboard: FoodAppendViewController?, row: Int) {
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        // アラートアクションシート一項目目
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { [self] _ in
            let inputView = storyboard
            guard let modalImput = inputView?.sheetPresentationController else {return}
                modalImput.detents = [.medium()]
            self.foodListPresenterOutput?.present(inputView: inputView)
            // 共通部分をここに収める
            inputView?.kindSelectText.isHidden = true
            inputView?.unitSelectButton.isEnabled = false
            inputView?.unitSelectButton.alpha = 1.0
            // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
            inputView?.foodKindsStacks.isHidden = true
            inputView?.parentStacKView.spacing = 50
            inputView?.nameTextHeightconstraint.constant = 20
            inputView?.quantityTextHeightConstraint.constant = 20
            FoodListPresenter.isTapRow = true
            if FoodListPresenter.isTapRow {
                // isManagingとおなじ条件を入れる
                if !self.foodUseCase.isFilteringFreezer && !self.foodUseCase.isFilteringRefrigerator && self.foodUseCase.selectedKinds.isEmpty {
                    guard let foodinRow = foodInRow(forRow: row) else { return }

                    inputView?.unitSelectButton.setTitle(inputView?.unitSelectButton.unitButtonTranslator(unit: self.array[row].unit), for: .normal)
                    inputView?.foodNameTextField.text = foodinRow.name
                    inputView?.quantityTextField.text = foodinRow.quantity
                } else {
                    guard let filteredfoodinRow = filteredFoodInRow(forRow: row) else { return }
                    inputView?.unitSelectButton.setTitle(inputView?.unitSelectButton.unitButtonTranslator(unit: filteredfoodinRow.unit), for: .normal)
                    inputView?.foodNameTextField.text = filteredfoodinRow.name
                    inputView?.quantityTextField.text = filteredfoodinRow.quantity
                }
                inputView?.preserveButton.addAction(.init(handler: { [self] _ in
                    // isManaging
                    if !foodUseCase.isFilteringFreezer && !foodUseCase.isFilteringRefrigerator && foodUseCase.selectedKinds.isEmpty {
                        guard let foodinRow = foodInRow(forRow: row) else { return }
                        self.didTapPreserveOnInputView(foodName: inputView?.foodNameTextField.text, foodQuantity: inputView?.quantityTextField.text, foodinArray: foodinRow)
                    } else {
                        guard let filteredfoodinRow = filteredFoodInRow(forRow: row) else { return }
                        self.didTapPreserveOnInputView(foodName: inputView?.foodNameTextField.text, foodQuantity: inputView?.quantityTextField.text, foodinArray: filteredfoodinRow)
                    }
                }), for: .touchUpInside)
                inputView?.refrigeratorButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.refrigerator.rawValue)"
                    ])
                    print("\(Food.Location.refrigerator.rawValue)")
                }), for: .touchUpInside)
                inputView?.freezerButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.freezer.rawValue)"
                    ])
                    print("\(Food.Location.freezer.rawValue)")
                }), for: .touchUpInside)
            }
        }))
        // アラートアクションシート二項目目
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ in
            if !self.foodUseCase.isFilteringFreezer && !self.foodUseCase.isFilteringRefrigerator && self.foodUseCase.selectedKinds.isEmpty {
                guard let foodinRow = self.foodInRow(forRow: row) else { return }
                self.foodListPresenterOutput?.performSegue(foodNameTextLabel: foodinRow.name)
            } else {
//                return filteredFoodInRow(forRow: row)
                guard let filteredfoodinRow = self.filteredFoodInRow(forRow: row) else { return }
                self.foodListPresenterOutput?.performSegue(foodNameTextLabel: filteredfoodinRow.name)
            }
//            self.foodListPresenterOutput?.performSegue(foodNameTextLabel: self.array[row].name) // foodNameTextLabel
        }))
        foodListPresenterOutput?.presentAlert(alert: alert)
        // アラートアクションシート三項目目
        alert.addAction(.init(title: "キャンセル", style: .destructive, handler: { _ in

        }))
    }
    private func didTapPreserveOnInputView(foodName: String?, foodQuantity: String?, foodinArray: Food) {
        print("inputのアクションが操作")
        self.db.collection("foods").document("IDkey: \(foodinArray.IDkey)").setData([
            "name": "\(foodName!)",
            "quantity": "\(foodQuantity!)",
            "date": "\(Date())",
            "IDkey": "\(foodinArray.IDkey)",
            "kind": "\(foodinArray.kind)",
            "unit": "\(foodinArray.unit)"
        ], merge: true) { err in
            if let err = err {
                print("FireStoreへの書き込みに失敗しました: \(err)")
                FoodListPresenter.isTapRow = false
            } else {
                print("FireStoreへの書き込みに成功しました")
                FoodListPresenter.isTapRow = false
            }
        }

        self.foodListPresenterOutput?.dismiss()
        FoodListPresenter.isTapRow = false
        // ここで読み込む
        foodData.fetch { result in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                switch result {
                case let .success(foods):
                    self.array = foods
                    self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                    // ここに入れることで起動時に表示
                    self.foodListPresenterOutput?.update()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    // スクロール時の動作

    // 食材ボタンを押した際の動作
    func kindButtonAnimation(kind: Food.FoodKind, _ button: UIButton) {
        if foodUseCase.foodKindDictionary[kind]! {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            button.backgroundColor = .lightGray
        } else {
            button.transform = CGAffineTransform(scaleX: 1, y: 1)
            button.backgroundColor = .clear
        }
    }
}
