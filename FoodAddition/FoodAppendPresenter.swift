//
//  FoodAppendPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/18.
//

import Foundation
import UIKit
import Firebase
//  ViewController側の処理を定義
protocol FoodAppendPresenterOutput: AnyObject {
    func setPlaceholderAndKeyboard()
    func dismiss()
    func didTapPreserveButtonWithoutEssential()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
    func resetButtonsImage()
    func animateButton(_ location: Food.Location)
}
// FoodAppendViewのPresenter
final class FoodAppendPresenter {
    private let foodData: FoodData
    private weak var foodAppendPresenterOutput: FoodAppendPresenterOutput?
    private var baseArray = Food(location: .refrigerator, kind: .other, name: String(), quantity: String(), unit: UnitSelectButton.UnitMenu.initial, IDkey: UUID().uuidString, date: Date())
//    private var uid: String = ""
    init(foodData: FoodData) {
        self.foodData = foodData
    }
    // インスタンス変数の中身をViewController側から注入させる
    func setOutput(foodAppendPresenterOutput: FoodAppendPresenterOutput?) {
        self.foodAppendPresenterOutput = foodAppendPresenterOutput
    }
    func settingVC() {
        self.foodAppendPresenterOutput?.setPlaceholderAndKeyboard()
//        self.uid = receivedUID
    }
    func settingTextField() {
        foodAppendPresenterOutput?.setPlaceholderAndKeyboard()
    }
    // isTapRowで条件決めし、選択内容をFood型のBaseArrayに保存
    func didTaplocationButton(location: Food.Location) {
        if FoodListPresenter.isTapRow == false {
            baseArray.location = location
            self.foodAppendPresenterOutput?.animateButton(location)
        } else {
            print("editの冷蔵ボタン")
        }
    }
    //　選択されたkindの選択内容をFood型のBaseArrayに保存
    func didTapKindButton(kind: Food.FoodKind, _ button: UIButton) {
        baseArray.kind = kind
        self.foodAppendPresenterOutput?.resetButtonsImage()
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
            button.setImage(image, for: .normal)
            print(baseArray.kind.kindNumber)
        }
    }
    // キャンセルボタンを押した際の処理
    func didTapCancelButton() {
        foodAppendPresenterOutput?.dismiss()
    }
    // isTapRowで条件決めし、保存ボタンを押した際の処理
    func didTapPreserveButton(foodName: String?, quantity: String?, unit: UnitSelectButton.UnitMenu) {
        if FoodListPresenter.isTapRow == false {
            self.foodAppendPresenterOutput?.didTapPreserveButtonWithoutEssential()
            if !foodName!.isEmpty && !quantity!.isEmpty && Int(quantity!) != nil && unit != .initial {
            if let foodName = foodName {
                baseArray.name = foodName
            } else {return}
            if let quantity = quantity {
                baseArray.quantity = quantity
            } else {return}
            baseArray.unit = unit
                guard let uid = Auth.auth().currentUser?.uid else {return}
                foodData.post(uid, self.baseArray) { result in
                switch result {
                case .success:
                    self.foodAppendPresenterOutput?.dismiss()
                    print("オリジナルのFuncが動作")
                case let .failure(error):
                    self.foodAppendPresenterOutput?.presentErrorIfNeeded(error)
                    print(error)
                }
            }
        }
        } else {
            print(FoodListPresenter.isTapRow)
        }
    }
    // isTapRowで条件決めし、Food型のBaseArrayに保存
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
}
