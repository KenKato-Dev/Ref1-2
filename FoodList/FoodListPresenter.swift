//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Foundation
protocol FoodListPresenterOutput: AnyObject {
    func update()
    func didRefreshSwipe()
    func isAppearingTrashBox(isDelete: Bool)
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
        foodData.fetchFoods { result in
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
        foodListPresenterOutput?.isAppearingTrashBox(isDelete: isDelete)
        if isDelete {
            // filterで値のみを取り出し、defoはTrueを取り出すため
            let filteredIDictionary = self.checkedID.filter {$0.value}.map {$0.key}
            self.foodData.delete(filteredIDictionary) { result in
                switch result {
                case.success:
                    // ここから
                    self.checkedID = [:]
                    self.foodData.fetchFoods { result in
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
    func didTapCheckBoxButton() {

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
    func locationTranslator(location: Food.Location) -> String {
        var trasnlatedlocation = String()
        if location == .refrigerator {
            trasnlatedlocation = "冷蔵"
        } else if location == .freezer {
            trasnlatedlocation = "冷凍"
        }
        return trasnlatedlocation
    }
    // TableView用Func
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
    func isTapCheckboxButton(row: Int) -> ((Bool) -> Void)? {
//        // UUIDをDictionaryに追加
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[row].IDkey] = isChecked
        }
        return didTapCheckBox
//        cell?.checkBoxButton.updateAppearance(isChecked: checkedIDDictionary[self.foodArray[indexPath.row].IDkey] ?? false)
//        // 下記でcheckBoxの削除後に再利用されるCell内のBool値をfalseにする
//        if !isChange {
//            cell?.checkBoxButton.isTap = false
//        }
    }
}
