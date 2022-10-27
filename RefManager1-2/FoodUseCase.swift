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
    var isFilteringRefrigerator = false
    var isFilteringFreezer = false
    // 下記を利用
    var selectedKinds: [Food.FoodKind] = []
    var foodFilter = FoodData.Fiter.init(location: .refrigerator, kindArray: Food.FoodKind.allCases)
    var foodKindDictionary: [Food.FoodKind: Bool] = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
            .seasoning: false, .sweet: false, .other: false
        ]

}
