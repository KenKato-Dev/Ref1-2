//
//  FoodUseCase.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/05/18.
//

import Foundation
import UIKit
class FoodUseCase {
    static let shared: FoodUseCase = FoodUseCase()
    var filterForRefrigerator = false
    var filterForFreezer = false
    // 下記を利用
    var selectedKinds: [Food.FoodKind] = []
    var foodFilter = FoodData.Fiter.init(location: .refrigerator, kind: Food.FoodKind.allCases)
    var foodKindDictionary: [Food.FoodKind: Bool] = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
            .seasoning: false, .sweet: false, .other: false
        ]
    // func動作せず、引数に外部の配列を入れても機能しない？
//    func addFilteredFood(foodLocation: [Food]) {
//        var foodLocation = foodLocation
//        foodLocation.append(contentsOf: FoodData.shared.filterationOfFood(with: FoodUseCase.shared.foodFilter))
//    }
}
