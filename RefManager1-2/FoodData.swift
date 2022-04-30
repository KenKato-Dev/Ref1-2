//
//  FoodData.swift
//  LikeTabTraining
//
//  Created by 加藤研太郎 on 2022/04/05.
//

import Foundation
import UIKit

struct Food {
    var refOrFreezer: RefOrFreezer
    var kind: FoodKind
    var name: String
    var quantity: Double
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date
    enum RefOrFreezer: String {
        case refrigerator = "冷蔵"
        case freezer = "冷凍"
    }
    enum FoodKind: String {
        case meat
        case fish
        case vegetableAndFruit
        case milkAndEgg
        case dish
        case drink
        case seasoning
        case sweet
        case other
    }
}
class FoodData {
    static let shared: FoodData = FoodData()
    private var foodsArray: [Food] = []

    func add(_ food: Food) {
        foodsArray.append(food)
    }
    func getfoodArray() -> [Food] {
        foodsArray
    }
    func removeFoods(key: String) {
        foodsArray.removeAll { food in
            food.IDkey == key
        }
    }
}
