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
//    private var foodLocation: [Food] = []
    var filterForRefrigerator = false
    var filterForFreezer = false

    func filterFoodLocation(boolForLocation: Bool, boolForAnotherLocation: Bool, location: Food.Location, foodLocation: [Food], foodFilter: FoodData.Fiter) {
        var boolForLocation = boolForLocation
        var boolForAnotherLocation = boolForAnotherLocation
        var foodLocation = foodLocation
        var location = location
        boolForAnotherLocation = false
        boolForLocation.toggle()
            foodLocation = []
            location = .refrigerator
            addFilteredFood(foodLocation: foodLocation, foodFilter: foodFilter)
//            print(self.foodLocation)
//            self.tableView.reloadData()

    }
    func addFilteredFood(foodLocation: [Food], foodFilter: FoodData.Fiter) {
        var foodLocation = foodLocation
        foodLocation.append(contentsOf: FoodData().filterationOfFood(with: foodFilter))
    }
}
