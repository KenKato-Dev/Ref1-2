//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Firebase
import Foundation
import UIKit
import Dispatch
protocol FoodListPresenterOutput: AnyObject {
    func reloadData()
    func present(inputView: FoodAppendViewController?)
    func presentAlert(alert: UIAlertController)
    func dismiss()
    func performSegue(foodNameTextLabel: String?)
    func setTitle(refigerator: Bool, freezer: Bool, selectedKinds: [Food.FoodKind], location: Food.Location)
    func didTapDeleteButton(isDelete: Bool)
    func animateButton(isFilteringRef: Bool, isFilteringFreezer: Bool)
    func resetButtonColor()
}

final class FoodListPresenter {
    private let foodData: FoodData
    private weak var foodListPresenterOutput: FoodListPresenterOutput?
    private(set) var array: [Food] = []
    private(set) var isDelete = true
    private(set) var checkedID: [String: Bool] = [:]
    private var didTapCheckBox: ((Bool) -> Void)?
    private(set) static var isTapRow = false
    private let foodUseCase: FoodUseCase
    private let db = Firestore.firestore()
    init(foodData: FoodData, foodUseCase: FoodUseCase) {
        self.foodData = foodData
        self.foodUseCase = foodUseCase
    }

    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }
    func isLoadingList() {
        isFetchingArray()
//        foodListPresenterOutput?.reloadData()
    }
    private func isFetchingArray() {
        self.foodData.isConfiguringQuery(
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds)
        self.foodData.fetch { result in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                switch result {
                case let .success(foods):
                    self.array = foods
                    self.array = self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                    self.foodListPresenterOutput?.reloadData()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    func didScrollToLast(row: Int) {
        if row == self.array.count - 1 && foodData.countOfDocuments != 0 {
            foodData.paginate()
            foodData.fetch { result in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    switch result {
                    case let .success(foods):
                        self.array.append(contentsOf: foods)
                        self.array = self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                        self.foodListPresenterOutput?.reloadData()
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
    func didTapDeleteButton() {
        isDelete.toggle()

        // ボタンの無効化
        foodListPresenterOutput?.didTapDeleteButton(isDelete: isDelete)
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
                                self.array = self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                                // このReloadにより削除がtableに反映
//                                self.foodListPresenterOutput?.reloadData()
                            case let .failure(error):
                                print("fetchfoodsに失敗:\(error)")
                            }
                            // 下記reloadがないと表示が反映されず1
                            self.foodListPresenterOutput?.reloadData()
                        }
                    case let .failure(error):
                        print("deleteに失敗:\(error)")
                    }
                }
                self.foodListPresenterOutput?.reloadData()
            }))
            alert.addAction(.init(title: "いいえ", style: .destructive, handler: { _ in
                self.checkedID = [:]
                print("削除をキャンセル")
            }))
            foodListPresenterOutput?.presentAlert(alert: alert)
        }
        foodListPresenterOutput?.reloadData()
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
        foodUseCase.resetKinds(foodUseCase.isFilteringRefrigerator, foodUseCase.isFilteringFreezer)
        // タイトル編集
        foodListPresenterOutput?.setTitle(
            refigerator: foodUseCase.isFilteringRefrigerator,
            freezer: foodUseCase.isFilteringFreezer,
            selectedKinds: foodUseCase.selectedKinds,
            location: foodUseCase.foodFilter.location
        )
        self.isFetchingArray()
        print(foodData.query)
        foodListPresenterOutput?.reloadData()
    }
    // 食材ボタン
    func didTapFoodKindButtons(kind: Food.FoodKind) {
        foodUseCase.toggleDictionary(kind: kind)
        let selectedDictionary = foodUseCase.foodKindDictionary.filter { $0.value == true }
        var selectedFoodKinds = selectedDictionary.map(\.key)
        foodUseCase.foodFilter.kindArray = selectedFoodKinds
        // ここで入る
        foodUseCase.isAddingKinds(selectedKinds: &selectedFoodKinds)
        self.isFetchingArray()
        print(foodData.query)
        foodListPresenterOutput?.reloadData()
    }
    // 食材を選択した状態で冷蔵冷凍ボタンを押した際に
    private func refreshFoodKindDictionary() {
        foodUseCase.resetDictionary()
        foodUseCase.foodFilter.kindArray = Food.FoodKind.allCases
        self.foodListPresenterOutput?.resetButtonColor()
    }
    /// UUIDをDictionaryに追加
    func isTapCheckboxButton(row: Int) -> ((Bool) -> Void)? {
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[row].IDkey] = isChecked

        }
        return didTapCheckBox
    }

    func isManagingArray(row: Int) -> Food? {

        if !foodUseCase.isFilteringFreezer && !foodUseCase.isFilteringRefrigerator && foodUseCase.selectedKinds.isEmpty {
            self.refreshFoodKindDictionary()
        }
        return array[row]
    }

    func numberOfRows() -> Int {
//        self.isFetchingArray()
        return self.array.count

    }
    func didSelectRow(storyboard: FoodAppendViewController?, row: Int) {
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        // アラートアクションシート一項目目
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { [self] _ in
            let inputView = storyboard
            guard let inputView = inputView else {return}
            guard let modalImput = inputView.sheetPresentationController else {return}
            modalImput.detents = [.medium()]

            self.foodListPresenterOutput?.present(inputView: inputView)
            // 共通部分をここに収める
            inputView.kindSelectText.isHidden = true
            inputView.unitSelectButton.isEnabled = false
            inputView.unitSelectButton.alpha = 1.0
            // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
            inputView.foodKindsStacks.isHidden = true
            inputView.parentStacKView.spacing = 50
            inputView.nameTextHeightconstraint.constant = 20
            inputView.quantityTextHeightConstraint.constant = 20
            FoodListPresenter.isTapRow = true
            if FoodListPresenter.isTapRow {

                    inputView.unitSelectButton.setTitle(inputView.unitSelectButton.unitButtonTranslator(unit: self.array[row].unit), for: .normal)
                inputView.foodNameTextField.text = self.array[row].name
                inputView.quantityTextField.text = self.array[row].quantity
                if !inputView.foodNameTextField.text!.isEmpty && !inputView.quantityTextField.text!.isEmpty {
                    inputView.preserveButton.isEnabled = true
                } else {
                    inputView.preserveButton.isEnabled = false
                }

                inputView.refrigeratorButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.refrigerator.rawValue)"
                    ])
                }), for: .touchUpInside)
                inputView.freezerButton.addAction(.init(handler: { _ in
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "location": "\(Food.Location.freezer.rawValue)"
                    ])
                }), for: .touchUpInside)
            }
                inputView.preserveButton.addAction(.init(handler: { [self] _ in

                    if inputView.foodNameTextField.text!.isEmpty {
                        inputView.foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                    }
                    if inputView.quantityTextField.text!.isEmpty {
                        inputView.quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                    if !inputView.foodNameTextField.text!.isEmpty && !inputView.quantityTextField.text!.isEmpty {
                        self.didTapPreserveOnInputView(foodName: inputView.foodNameTextField.text, foodQuantity: inputView.quantityTextField.text, foodinArray: self.array[row])
                    }
                }), for: .touchUpInside)
        }))
        // アラートアクションシート二項目目
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ in
            self.foodListPresenterOutput?.performSegue(foodNameTextLabel: self.array[row].name)
        }))
        foodListPresenterOutput?.presentAlert(alert: alert)
        // アラートアクションシート三項目目
        alert.addAction(.init(title: "キャンセル", style: .destructive, handler: { _ in
        }))
    }

    private func didTapPreserveOnInputView(foodName: String?, foodQuantity: String?, foodinArray: Food) {
        print("inputのアクションが操作")
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "queue")
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
        self.foodData.isConfiguringQuery(
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds)
        self.foodData.fetch { result in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                switch result {
                case let .success(foods):
                    self.array = foods
                    print(self.array)
                    self.array = self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                    // ここに入れることで起動時に表示
                    self.foodListPresenterOutput?.reloadData()
                case let .failure(error):
                    print(error)

                }
            }
        }
            self.foodListPresenterOutput?.dismiss()
    }

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
