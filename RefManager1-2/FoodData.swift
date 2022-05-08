//
//  FoodData.swift
//  LikeTabTraining
//
//  Created by 加藤研太郎 on 2022/04/05.
//

import Foundation
import UIKit

struct Food {
    var location: Location
    var kind: FoodKind
    var name: String
    var quantity: Double
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date
    enum Location: String {
        case refrigerator = "冷蔵"
        case freezer = "冷凍"
    }
    // CaseIterableでallCasesが使用可能になる
    enum FoodKind: String, CaseIterable {
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
    struct Fiter {
        var location: Food.Location
        var kind: [Food.FoodKind]
    }
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
    func filterationOfFood(with filter: Fiter) -> [Food] {
        // containsはBoolであり含まれていたらtrueを返す
        foodsArray.filter {filter.kind.contains($0.kind) && $0.location == filter.location}
        }
    }
