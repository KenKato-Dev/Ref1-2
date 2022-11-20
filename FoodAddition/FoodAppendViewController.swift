//
//  ModalViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class FoodAppendViewController: UIViewController {
    private let foodAppendPresenter = FoodAppendPresenter(foodData: FoodData())
    @IBOutlet var foodNameTextField: UITextField!
    @IBOutlet var nameTextHeightconstraint: NSLayoutConstraint!
    @IBOutlet var methodSelectText: UILabel!
    @IBOutlet var refrigeratorButton: UIButton!
    @IBOutlet var freezerButton: UIButton!
    @IBOutlet var kindSelectText: UILabel!
    @IBOutlet var foodKindsStacks: UIStackView!
    @IBOutlet var meatButton: UIButton!
    @IBOutlet var fishButton: UIButton!
    @IBOutlet var vegetableAndFruitButton: UIButton!
    @IBOutlet var milkAndEggButton: UIButton!
    @IBOutlet var dishButton: UIButton!
    @IBOutlet var drinkButton: UIButton!
    @IBOutlet var seasoningButton: UIButton!
    @IBOutlet var sweetButton: UIButton!
    @IBOutlet var othersButton: UIButton!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var quantityTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet var unitSelectButton: UnitSelectButton!
    @IBOutlet var parentStacKView: UIStackView!
    @IBOutlet var buttonsStack: UIStackView!
    @IBOutlet var preserveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameTextField.delegate = self
        quantityTextField.delegate = self

        settingTextfield()
        foodAppendPresenter.setOutput(foodAppendPresenterOutput: self)

        // 冷蔵ボタン
        refrigeratorButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTaplocationButton(location: .refrigerator)
        }), for: .touchUpInside)
        // 冷凍ボタン
        freezerButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTaplocationButton(location: .freezer)
        }), for: .touchUpInside)
        meatButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .meat)
        }), for: .touchUpInside)
        fishButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .fish)
        }), for: .touchUpInside)
        vegetableAndFruitButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .vegetableAndFruit)
        }), for: .touchUpInside)
        milkAndEggButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .milkAndEgg)
        }), for: .touchUpInside)
        dishButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .dish)
        }), for: .touchUpInside)
        drinkButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .drink)
        }), for: .touchUpInside)
        seasoningButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .seasoning)
        }), for: .touchUpInside)
        sweetButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .sweet)
        }), for: .touchUpInside)
        othersButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .other)
        }), for: .touchUpInside)
        unitSelectButton.selectingUnit()
        // UIMENUのボタンはViewが描写された瞬間に呼ばれるため
//        unitSelectButton.addAction(.init(handler: { _ in
//            if !self.foodNameTextField.text!.isEmpty && !self.foodNameTextField.text!.isEmpty && self.unitSelectButton.selectedUnit != .initial {
//                self.preserveButton.isEnabled = true
//            } else {
//                self.preserveButton.isEnabled = false
//            }
//        }), for: .touchUpInside)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
//        self.foodAppendPresenter.didEditingTextFields(foodName: foodNameTextField.text, quantity: quantityTextField.text, unit: unitSelectButton.selectedUnit)
        self.foodAppendPresenter.disablingPreserveButton()
        print("hide作動")
    }

    @IBAction func cancel(_: Any) {
        foodAppendPresenter.didTapCancelButton()
    }

    @IBAction func preserve(_: Any) {
        foodAppendPresenter.didTapPreserveButton(foodName: foodNameTextField.text, quantity: quantityTextField.text, unit: unitSelectButton.selectedUnit)
    }
}

extension FoodAppendViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if !self.foodNameTextField.text!.isEmpty || !self.foodNameTextField.text!.isEmpty || unitSelectButton.selectedUnit != .initial { //
//            self.preserveButton.isEnabled = true
//        } else {
//            self.preserveButton.isEnabled = false
//        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FoodAppendViewController: FoodAppendPresenterOutput {
    func settingTextfield() {
        let foodTextAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15.0),
            .foregroundColor: UIColor.gray
        ]
        let quantityTextAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15.0),
            .foregroundColor: UIColor.gray
        ]
        foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: foodTextAttribute)
        quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: quantityTextAttribute)
        quantityTextField.keyboardType = .numberPad
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        // 初期で無効化
        self.preserveButton.isEnabled = false
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    func didTapPreserveButtonWithoutEssential() {
        if !self.foodNameTextField.text!.isEmpty && !self.quantityTextField.text!.isEmpty && unitSelectButton.selectedUnit != .initial {
            self.preserveButton.isEnabled = true
        } else {
            self.preserveButton.isEnabled = false
        }
    }
}
