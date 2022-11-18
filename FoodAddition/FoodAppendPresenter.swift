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
    private weak var foodAppendPresenterOutput: FoodAppendPresenterOutput?
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
            baseArray.location = location
        } else {
            print("editの冷蔵ボタン")
        }
    }

    func didTapKindButton(kind: Food.FoodKind) {
        baseArray.kind = kind
    }

    func didTapCancelButton() {
        foodAppendPresenterOutput?.dismiss()
    }

    func didTapPreserveButton(foodName: String?, quantity: String?, unit: UnitSelectButton.UnitMenu) {
        if FoodListPresenter.isTapRow == false {
            if let foodName = foodName {
                baseArray.name = foodName
            }
            if let quantity = quantity {
                baseArray.quantity = quantity
            }
//             = String(Double(quantityTextField.text!) ?? 0.0) ?? "0.0"
            baseArray.unit = unit
//            FoodData.shared.add(baseArray)
            foodData.post(baseArray)
            foodAppendPresenterOutput?.dismiss()
            print("オリジナルのFuncが動作")
        } else {
            print(FoodListPresenter.isTapRow)
        }
    }
}
