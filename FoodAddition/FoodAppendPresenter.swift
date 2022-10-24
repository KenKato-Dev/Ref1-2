//
//  FoodAppendPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/18.
//

import Foundation
protocol FoodAppendPresenterOutput: AnyObject {
    func settingTextfield()
    func dismiss()
}
final class FoodAppendPresenter {
    private let foodData: FoodData
    weak private var foodAppendPresenterOutput: FoodAppendPresenterOutput?
    private var baseArray = Food(location: .refrigerator, kind: .other, name: String(), quantity: String(), unit: UnitSelectButton.UnitMenu.initial, IDkey: UUID().uuidString, date: Date())
    init(foodData: FoodData) {
        self.foodData = foodData
    }
    func setOutput(foodAppendPresenterOutput: FoodAppendPresenterOutput?) {
        self.foodAppendPresenterOutput = foodAppendPresenterOutput
    }
    func settingTextField() {
        foodAppendPresenterOutput?.settingTextfield()
    }
    func didTaplocationButton(location: Food.Location) {
        if FoodListPresenter.isTapRow == false {
            self.baseArray.location = location
        } else {
            print("editの冷蔵ボタン")
        }
    }
    func didTapKindButton(kind: Food.FoodKind) {
        self.baseArray.kind = kind
    }
    func didTapCancelButton() {
        self.foodAppendPresenterOutput?.dismiss()
    }
    func didTapPreserveButton(foodName: String?, quantity: String?, unit: UnitSelectButton.UnitMenu) {
        if FoodListPresenter.isTapRow == false {
            if let foodName = foodName {
                self.baseArray.name = foodName
            }
            if let quantity = quantity {
                self.baseArray.quantity = quantity
            }
//             = String(Double(quantityTextField.text!) ?? 0.0) ?? "0.0"
            self.baseArray.unit = unit
//            FoodData.shared.add(baseArray)
            self.foodData.addtoDataBase(self.baseArray)
            self.foodAppendPresenterOutput?.dismiss()
            print("オリジナルのFuncが動作")
        } else {
            print(FoodListPresenter.isTapRow)
        }
    }
}
