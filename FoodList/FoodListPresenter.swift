//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Firebase
import Foundation
protocol FoodListPresenterOutput: AnyObject {
    func update()
    func didRefreshSwipe()
    func isAppearingTrashBox(isDelete: Bool)
    func present(inputView: FoodAppendViewController?)
    func presentAlert(alert: UIAlertController)
    func dismiss()
    func performSegue(foodNameTextLabel: String?)
    func setTitle(refigerator: Bool, freezer: Bool, selectedKinds: [Food.FoodKind], location: Food.Location)
    func isHidingButtons(isDelete: Bool)
    func buttonAnimation(isFilteringRef: Bool, isFilteringFreezer: Bool)
}

final class FoodListPresenter {
    private let foodData: FoodData
    private weak var foodListPresenterOutput: FoodListPresenterOutput?
    //    private let foodUseCase = FoodUseCase.shared
    private(set) var array: [Food] = []
    private var filteredArray: [Food] = []
    private(set) var isDelete = true
    private(set) var checkedID: [String: Bool] = [:]
    //    private let sharedFoodUseCase = FoodUseCase.shared
    private var didTapCheckBox: ((Bool) -> Void)?
    private(set) static var isTapRow = false
    // static foodUseCaseを消す
    private let foodUseCase: FoodUseCase
    private let db = Firestore.firestore()

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
        foodListPresenterOutput?.didRefreshSwipe()
        foodListPresenterOutput?.update()
    }

    func loadArray() {
        foodData.fetch { result in
            switch result {
            case let .success(foods):
                self.array = foods
                self.foodListPresenterOutput?.update()
            case let .failure(error):
                print(error)
                // Alart表示
            }
        }
    }

    func didTapDeleteButton() {
        isDelete.toggle()
        // 削除事に配列を元に戻す
        foodUseCase.isFilteringFreezer = false
        foodUseCase.isFilteringRefrigerator = false
        foodUseCase.selectedKinds = []
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
        foodUseCase.isFilteringRefrigerator.toggle()
        foodUseCase.isFilteringFreezer = false
        // ボタンの色を変更
        foodListPresenterOutput?.buttonAnimation(isFilteringRef: foodUseCase.isFilteringRefrigerator, isFilteringFreezer: foodUseCase.isFilteringFreezer)
        didSwitchLocation(location: .refrigerator)
    }

    // 冷凍ボタン
    func didTapFreezerButton(_: UIButton) {
        foodUseCase.isFilteringFreezer.toggle()
        foodUseCase.isFilteringRefrigerator = false
        foodListPresenterOutput?.buttonAnimation(isFilteringRef: foodUseCase.isFilteringRefrigerator, isFilteringFreezer: foodUseCase.isFilteringFreezer)
        didSwitchLocation(location: .freezer)
    }

    // 冷蔵冷凍ボタンを押した際実行する
    func didSwitchLocation(location: Food.Location) {
        if foodUseCase.selectedKinds.isEmpty {
            filteredArray = array
        }
        foodUseCase.foodFilter.location = location
        foodUseCase.selectedKinds = []
        //        self.filteredArray = filteredArray.filter {$0.location == self.foodUseCase.foodFilter.location}
        filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }.filter { foodUseCase.foodFilter.kindArray.contains($0.kind) }
        if filteredArray.isEmpty {
            filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }
        }
        //        self.configure(location: location)
        // タイトル編集
        foodListPresenterOutput?.setTitle(
            refigerator: foodUseCase.isFilteringRefrigerator,
            freezer: foodUseCase.isFilteringFreezer,
            selectedKinds: foodUseCase.selectedKinds,
            location: foodUseCase.foodFilter.location
        )
        refreshFoodKindDictionary()
        foodListPresenterOutput?.update()
    }

    // 食材ボタン
    func didTapFoodKindButtons(kind: Food.FoodKind) {
        //        self.refreshFoodKindDictionary()
        foodUseCase.foodKindDictionary[kind]!.toggle()
        let selectedDictionary = foodUseCase.foodKindDictionary.filter { $0.value == true }
        let selectedFoodKinds = selectedDictionary.map(\.key)
        // 食材ボタンを押した際に実行する　didSelectKinds(kinds: [Food.FoodKind])
        foodUseCase.foodFilter.kindArray = selectedFoodKinds
        // ここで入る
        foodUseCase.selectedKinds = selectedFoodKinds
        // selectedKindsが既に入っている場合はfilteredArrayから処理するように実施
        // self.array.filter
        filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }.filter { foodUseCase.foodFilter.kindArray.contains($0.kind) }
        if filteredArray.isEmpty {
            filteredArray = array.filter { foodUseCase.foodFilter.kindArray.contains($0.kind) }
        }
        //        self.filteredArray = self.filteredArray.filter {foodUseCase.foodFilter.kindArray.contains($0.kind)}
        // 配列がからの状態でもリセットしてはならない
        //        if filteredArray.isEmpty {
        //            self.filteredArray = self.array
        //            // 以下追記
        //        }

        //        else if (self.foodUseCase.isFilteringRefrigerator ||
        //                  self.foodUseCase.isFilteringFreezer) &&
        //                    (!self.foodUseCase.selectedKinds.isEmpty) {
        //            self.filteredArray = self.filteredArray.filter {foodUseCase.foodFilter.kindArray.contains($0.kind)}
        //        }
        //        self.configure(location: self.foodUseCase.foodFilter.location)
        if foodUseCase.selectedKinds.isEmpty {}

        foodListPresenterOutput?.update()
    }

    // 食材を選択した状態で冷蔵冷凍ボタンを押した際に
    private func refreshFoodKindDictionary() {
        if !foodUseCase.isFilteringRefrigerator,
           !foodUseCase.isFilteringFreezer,
           foodUseCase.selectedKinds.isEmpty
        {
            foodUseCase.foodKindDictionary = [
                .meat: false, .fish: false, .vegetableAndFruit: false,
                .milkAndEgg: false, .dish: false, .drink: false,
                .seasoning: false, .sweet: false, .other: false,
            ]
        }
    }

    // 上記食材ボタン,冷凍冷蔵ボタンによる配列への操作を下記に集約させる
    private func configure(location: Food.Location) {
        let selectedDictionary = foodUseCase.foodKindDictionary.filter { $0.value == true }
        let selectedFoodKinds = selectedDictionary.map(\.key)
        foodUseCase.selectedKinds = selectedFoodKinds
        foodUseCase.foodFilter.location = location
        foodUseCase.foodFilter.kindArray = selectedFoodKinds
        if !foodUseCase.isFilteringRefrigerator,
           !foodUseCase.isFilteringFreezer,
           foodUseCase.selectedKinds.isEmpty
        {
            filteredArray = array
        } else if foodUseCase.selectedKinds.isEmpty {
            filteredArray = array.filter { $0.location == self.foodUseCase.foodFilter.location }
        } else {
            filteredArray = filteredArray.filter { $0.location == self.foodUseCase.foodFilter.location }
        }
    }

    func isTapCheckboxButton(row: Int) -> ((Bool) -> Void)? {
        //        // UUIDをDictionaryに追加
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[row].IDkey] = isChecked
        }
        return didTapCheckBox
    }

    // TableView用Func、ここで配列に入れるものを決めている
    // ここの修正により配列管理を改善、Filtered FoodInRowの改善
    func isManagingArray(row: Int) -> Food? {
        if !foodUseCase.isFilteringFreezer,
           !foodUseCase.isFilteringRefrigerator,
           foodUseCase.selectedKinds.isEmpty
        {
            //            self.refreshFoodKindDictionary()
            return foodInRow(forRow: row)
        } else {
            return filteredFoodInRow(forRow: row)
        }
    }

    private func foodInRow(forRow row: Int) -> Food? {
        guard row < array.count else { return nil }
        return array[row]
    }

    private func filteredFoodInRow(forRow row: Int) -> Food? {
        guard row < filteredArray.count else { return nil }
        return filteredArray[row]
    }

    func numberOfRows() -> Int {
        if !foodUseCase.isFilteringFreezer,
           !foodUseCase.isFilteringRefrigerator,
           foodUseCase.selectedKinds.isEmpty
        {
            return array.count
        } else {
            return filteredArray.count
        }
    }

    func didSelectRow(storyboard: FoodAppendViewController?, row: Int) {
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { _ in
            let inputView = storyboard
            if let modalImput = inputView?.sheetPresentationController {
                modalImput.detents = [.medium()]
            } else {
                print("エラーです")
            }
            self.foodListPresenterOutput?.present(inputView: inputView)
            // ここでPlaceholderを
            inputView?.foodNameTextField.placeholder = self.array[row].name
            inputView?.quantityTextField.placeholder = self.array[row].quantity
            inputView?.kindSelectText.isHidden = true
            // 数値を変更しようとした際にクラッシュThread 1: EXC_BAD_ACCESS (code=2, address=0x1d82cd1d0)
            inputView?.unitSelectButton.setTitle(inputView?.unitSelectButton.unitButtonTranslator(unit: self.array[row].unit), for: .normal)
            inputView?.unitSelectButton.isEnabled = false
            inputView?.unitSelectButton.alpha = 1.0
            // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
            inputView?.foodKindsStacks.isHidden = true
            inputView?.parentStacKView.spacing = 50
            inputView?.nameTextHeightconstraint.constant = 20
            inputView?.quantityTextHeightConstraint.constant = 20
            FoodListPresenter.isTapRow = true
            if FoodListPresenter.isTapRow == true {
                // placeholderでなくそのまま入力
                if (inputView?.foodNameTextField.state)!.isEmpty {
                    inputView?.foodNameTextField.text = self.array[row].name
                }
                if (inputView?.quantityTextField.state)!.isEmpty {
                    inputView?.quantityTextField.text = self.array[row].quantity
                }
                inputView?.preserveButton.addAction(.init(handler: { [self] _ in
                    print("inputのアクションが操作")
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "name": "\((inputView?.foodNameTextField.text)!)",
                        "quantity": "\((inputView?.quantityTextField.text)!)",
                        "date": "\(Date())",
                        "IDkey": "\(self.array[row].IDkey)",
                        "kind": "\(self.array[row].kind)",
                        "unit": "\(self.array[row].unit)",
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
                                // ここに入れることで起動時に表示
                                self.foodListPresenterOutput?.update()
                            case let .failure(error):
                                print(error)
                            }
                        }
                    }
                }), for: .touchUpInside)
                inputView?.refrigeratorButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.refrigerator.rawValue)",
                    ])
                    print("\(Food.Location.refrigerator.rawValue)")
                }), for: .touchUpInside)
                inputView?.freezerButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.freezer.rawValue)",
                    ])
                    print("\(Food.Location.freezer.rawValue)")
                }), for: .touchUpInside)
            }
        }))
        // アラートアクションシート二項目目
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ in
            self.foodListPresenterOutput?.performSegue(foodNameTextLabel: self.array[row].name) // foodNameTextLabel
        }))
        foodListPresenterOutput?.presentAlert(alert: alert)
        alert.addAction(.init(title: "キャンセル", style: .destructive, handler: { _ in

        }))
    }

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
