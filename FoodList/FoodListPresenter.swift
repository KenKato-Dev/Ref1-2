//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Foundation
protocol FoodListPresenterOutput: AnyObject {
    func didLoadView()
}
final class FoodListPresenter {
    private let foodData: FoodData
    weak private var foodListPresenterOutput: FoodListPresenterOutput?
    private let foodUseCase = FoodUseCase.shared
    private var array: [Food]=[]
    private var filteredArray: [Food]=[]
    private var isDelete = false

    init(foodData: FoodData) {
        self.foodData = foodData
    }
    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }
    func didTapDeleteButton() {

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
        foodListPresenterOutput?.didLoadView()
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
        foodListPresenterOutput?.didLoadView()
    }
    // TableView用Func
    func foodInRow(forRow row: Int) -> Food? {
        guard row < array.count else {return nil}
        return array[row]
    }
    func isTapDeleteButton() {
        self.isDelete.toggle()
        //self.deleteButton.imageChange(bool: self.isChange)
        if isDelete {
            
        }
    }
}
