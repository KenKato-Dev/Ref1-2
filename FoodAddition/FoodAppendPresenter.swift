//
//  FoodAppendPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/18.
//

import Foundation
import UIKit
protocol FoodAppendPresenterOutput: AnyObject {
    func settingTextfield()
    func dismiss()
    func didTapPreserveButtonWithoutEssential()
    func resettingButtonsImage()
    func animateButton(_ location: Food.Location)
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
            self.foodAppendPresenterOutput?.animateButton(location)
        } else {
            print("editの冷蔵ボタン")
        }
    }

    func didTapKindButton(kind: Food.FoodKind, _ button: UIButton) { //
        baseArray.kind = kind
        self.foodAppendPresenterOutput?.resettingButtonsImage()
//        let image = button.imageView!.image!.compositeImage(
//            UIImage(named: kind.rawValue + "Button")!,
//            button.imageView!.image!,
//            UIImage(named: "selectedButton")!,
//            0.5)
        var image = UIImage(named: kind.rawValue + "Button")
        if button.imageView!.image == UIImage(named: kind.rawValue + "Button") {
            image = button.imageView!.image!.compositeImage(
                UIImage(named: kind.rawValue + "Button")!,
                button.imageView!.image!,
                UIImage(named: "selectedButton")!,
                0.5)
        }
        if baseArray.kind == kind {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            button.setImage(image, for: .normal)
            button.imageView?.image
//            button.isHighlighted = true
        }
    }

    func didTapCancelButton() {
        foodAppendPresenterOutput?.dismiss()
    }

    func didTapPreserveButton(foodName: String?, quantity: String?, unit: UnitSelectButton.UnitMenu) {
        //
        if FoodListPresenter.isTapRow == false {
//        if foodName!.isEmpty {
//            foodName!.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//
//        }
//        if quantity!.isEmpty {
//            self!.quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//        }
            self.foodAppendPresenterOutput?.didTapPreserveButtonWithoutEssential()
        if !foodName!.isEmpty && !quantity!.isEmpty {
            if let foodName = foodName {
                baseArray.name = foodName
            }
            if let quantity = quantity {
                baseArray.quantity = quantity
            }
            baseArray.unit = unit
            foodData.post(baseArray)
            foodAppendPresenterOutput?.dismiss()
            print("オリジナルのFuncが動作")
        }
        //
        } else {
            print(FoodListPresenter.isTapRow)
        }
    }
    func didEditingTextFields(foodName: String?, quantity: String?, unit: UnitSelectButton.UnitMenu) {
        if FoodListPresenter.isTapRow == false {
            if let foodName = foodName {
                baseArray.name = foodName
            }
            if let quantity = quantity {
                baseArray.quantity = quantity
            }
            baseArray.unit = unit
            print("オリジナルのFuncが動作")
        } else {
            print(FoodListPresenter.isTapRow)
        }
    }
//    func disablingPreserveButton() {
//        if FoodListPresenter.isTapRow == false {
//        self.foodAppendPresenterOutput?.didTapPreserveButtonWithoutEssential()
//        }
//    }
}
