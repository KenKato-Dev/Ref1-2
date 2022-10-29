//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Foundation
import Firebase
protocol FoodListPresenterOutput: AnyObject {
    func update()
    func didRefreshSwipe()
    func isAppearingTrashBox(isDelete: Bool)
    func present(inputView: FoodAppendViewController?)
    func presentRecepie(alert: UIAlertController)
    func dismiss()
    func performSegue(foodNameTextLabel: String?)
    func setTitle(location: Food.Location)
    func disableButtons(isDelete: Bool)
    }

final class FoodListPresenter {
    private let foodData: FoodData
    weak private var foodListPresenterOutput: FoodListPresenterOutput?
    private let foodUseCase = FoodUseCase.shared
    private (set) var array: [Food]=[]
    private var filteredArray: [Food]=[]
    private (set) var isDelete = true
    private (set) var checkedID: [String: Bool] = [:]
    private let sharedFoodUseCase = FoodUseCase.shared
    private var didTapCheckBox: ((Bool) -> Void)?
    static private(set) var isTapRow = false
    private let db = Firestore.firestore()

    init(foodData: FoodData) {
        self.foodData = foodData
    }
    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }
    func didLoadView() {
        self.loadArray()
        self.foodListPresenterOutput?.update()
    }
    func willViewAppear() {
        self.foodListPresenterOutput?.didRefreshSwipe()
        self.foodListPresenterOutput?.update()
    }
    func loadArray() {
        foodData.fetch { result in
            switch result {
            case .success(let foods):
                self.array = foods
                self.foodListPresenterOutput?.update()
            case .failure(let error):
                print(error)
                // Alart表示
            }
        }
    }
    func didTapDeleteButton() {
        isDelete.toggle()
        // 削除事に配列を元に戻す
        sharedFoodUseCase.isFilteringFreezer = false
        sharedFoodUseCase.isFilteringRefrigerator = false
        sharedFoodUseCase.selectedKinds = []
        // ボタンの無効化
        foodListPresenterOutput?.disableButtons(isDelete: isDelete)
        //
        foodListPresenterOutput?.isAppearingTrashBox(isDelete: isDelete)
        if isDelete {
            // filterで値のみを取り出し、defoはTrueを取り出すため
            let filteredIDictionary = self.checkedID.filter {$0.value}.map {$0.key}
            self.foodData.delete(filteredIDictionary) { result in
                switch result {
                case.success:
                    // ここから
                    self.checkedID = [:]
                    self.foodData.fetch { result in
                        switch result {
                        case .success(let foods):
                            self.array = foods
                            // このReloadにより削除がtableに反映
                            self.foodListPresenterOutput?.update()
                        case .failure(let error):
                            print("fetchfoodsに失敗:\(error)")
                        }
                        // 下記reloadがないと表示が反映されず1
                        self.foodListPresenterOutput?.update()
                    }
                case.failure(let error):
                    print("deleteに失敗:\(error)")
                }
            }
            self.foodListPresenterOutput?.update()
        }
        self.foodListPresenterOutput?.update()
    }
    // 冷蔵ボタン
    func didTapRefrigiratorButton() {
        foodUseCase.isFilteringRefrigerator.toggle()
        foodUseCase.isFilteringFreezer = false
        didSwitchLocation(location: .refrigerator)
    }
    // 冷凍ボタン
    func didTapFreezerButton() {
        self.foodUseCase.isFilteringFreezer.toggle()
        self.foodUseCase.isFilteringRefrigerator = false
        self.didSwitchLocation(location: .freezer)
    }
    // 冷蔵冷凍ボタンを押した際実行する
    func didSwitchLocation(location: Food.Location) {
        if self.foodUseCase.selectedKinds.isEmpty {
            self.filteredArray = self.array
        }
        self.foodUseCase.foodFilter.location = location
        self.foodUseCase.selectedKinds = []
        self.filteredArray = filteredArray.filter {$0.location == self.foodUseCase.foodFilter.location}
        foodListPresenterOutput?.update()
    }
    // 食材ボタン
    func didTapFoodKindButtons(kind: Food.FoodKind) {
        self.foodUseCase.foodKindDictionary[kind]!.toggle()
        let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
        let kinds = selectedKinds.map {$0.key}
        // 食材ボタンを押した際に実行する　didSelectKinds(kinds: [Food.FoodKind])
        self.foodUseCase.foodFilter.kindArray = kinds
        self.foodUseCase.selectedKinds = kinds
        self.filteredArray = self.array.filter {foodUseCase.foodFilter.kindArray.contains($0.kind)}
                if filteredArray.isEmpty {
            self.filteredArray = self.array
        }
        foodListPresenterOutput?.update()
    }
    // 冷蔵冷凍を文字で返す
//    func locationTranslator(location: Food.Location) -> String {
//        var trasnlatedlocation = String()
//        if location == .refrigerator {
//            trasnlatedlocation = "冷蔵"
//        } else if location == .freezer {
//            trasnlatedlocation = "冷凍"
//        }
//        return trasnlatedlocation
//    }
    func isTapCheckboxButton(row: Int) -> ((Bool) -> Void)? {
        //        // UUIDをDictionaryに追加
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[row].IDkey] = isChecked
        }
        return didTapCheckBox
    }
    // TableView用Func
    func configure(row: Int) -> Food? {
        if (!self.sharedFoodUseCase.isFilteringFreezer &&
            !self.sharedFoodUseCase.isFilteringRefrigerator) &&
            (self.sharedFoodUseCase.selectedKinds.isEmpty) {
            return self.foodInRow(forRow: row)
        } else {
            return self.filteredFoodInRow(forRow: row)
        }
    }
    func foodInRow(forRow row: Int) -> Food? {
        guard row < array.count else {return nil}
        return array[row]
    }
    func filteredFoodInRow(forRow row: Int) -> Food? {
        guard row < filteredArray.count else {return nil}
        return filteredArray[row]
    }
    func numberOfRows() -> Int {
        if (!sharedFoodUseCase.isFilteringFreezer &&
            !sharedFoodUseCase.isFilteringRefrigerator) &&
            (self.sharedFoodUseCase.selectedKinds.isEmpty) {
            return self.array.count
        } else {
            return filteredArray.count
        }
    }
    func didSelectRow(storyboard: FoodAppendViewController?, row: Int, foodNameTextLabel: String?, quantityTextLabel: String?) {
        var foodNameTextLabel = foodNameTextLabel
        var quantityTextLabel = quantityTextLabel
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { _ -> Void in
            let inputView = storyboard
            if let modalImput = inputView?.sheetPresentationController {
                modalImput.detents = [.medium()]
            } else {
                print("エラーです")
            }
            self.foodListPresenterOutput?.present(inputView: inputView)
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
                inputView?.preserveButton.addAction(.init(handler: { [self]_ in
                    foodNameTextLabel = inputView?.foodNameTextField.text
                    quantityTextLabel = inputView?.quantityTextField.text
                    print("inputのアクションが操作")
                    self.db.collection("foods").document("IDkey: \(self.array[row].IDkey)").setData([
                        "name": "\((inputView?.foodNameTextField.text)!)",
                        "quantity": "\((inputView?.quantityTextField.text)!)",
                        "date": "\(Date())",
                        "IDkey": "\(self.array[row].IDkey)",
                        "kind": "\(self.array[row].kind)",
                        "unit": "\(self.array[row].unit)"
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
                            case .success(let foods):
                                self.array = foods
                                // ここに入れることで起動時に表示
                                self.foodListPresenterOutput?.update()
                            case .failure(let error):
                                print(error)
                            }
                        }
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
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ ->Void in
            self.foodListPresenterOutput?.performSegue(foodNameTextLabel: foodNameTextLabel)
        }))
        self.foodListPresenterOutput?.presentRecepie(alert: alert)
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: { _ in

        }))

    }
}
