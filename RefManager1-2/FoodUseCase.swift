//
//  FoodUseCase.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/05/18.
//

import Foundation
import UIKit
final class FoodUseCase {
//    enum ManagingArray {
//        case empty(location:Food.Location)
//        case didSelectKind(location:Food.Location)
//    }
//    static let shared: FoodUseCase = FoodUseCase()
    //    var managingArray:ManagingArray = .empty(location: .refrigerator)
    private (set) var isFilteringRefrigerator = false
    private (set) var isFilteringFreezer = false
    private (set) var selectedKinds: [Food.FoodKind] = []
    var foodFilter = FoodData.Fiter(location: .refrigerator, kindArray: Food.FoodKind.allCases)
    private (set) var foodKindDictionary: [Food.FoodKind: Bool] = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
        .seasoning: false, .sweet: false, .other: false
    ]
    func didTapRefrigeratorButton() {
        self.isFilteringRefrigerator.toggle()
        self.isFilteringFreezer = false
    }

    func didTapFreezerButton() {
        self.isFilteringFreezer.toggle()
        self.isFilteringRefrigerator = false
    }
    func isAddingKinds(selectedKinds: inout [Food.FoodKind]) {
        self.selectedKinds = selectedKinds
    }
    func resetKinds() {
        self.selectedKinds = []
    }
    func toggleDictionary(kind: Food.FoodKind) {
        self.foodKindDictionary[kind]!.toggle()
    }
    func resetDictionary() {
    foodKindDictionary = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
        .seasoning: false, .sweet: false, .other: false
        ]
    }
}
