//
//  ModalViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class FoodAppendViewController: UIViewController {

    private let foodAppendPresenter=FoodAppendPresenter(foodData: FoodData())
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var nameTextHeightconstraint: NSLayoutConstraint!
    @IBOutlet weak var methodSelectText: UILabel!
    @IBOutlet weak var refrigeratorButton: UIButton!
    @IBOutlet weak var freezerButton: UIButton!
    @IBOutlet weak var kindSelectText: UILabel!
    @IBOutlet weak var foodKindsStacks: UIStackView!
    @IBOutlet weak var meatButton: UIButton!
    @IBOutlet weak var fishButton: UIButton!
    @IBOutlet weak var vegetableAndFruitButton: UIButton!
    @IBOutlet weak var milkAndEggButton: UIButton!
    @IBOutlet weak var dishButton: UIButton!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var seasoningButton: UIButton!
    @IBOutlet weak var sweetButton: UIButton!
    @IBOutlet weak var othersButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unitSelectButton: UnitSelectButton!
    @IBOutlet weak var parentStacKView: UIStackView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var preserveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingTextfield()
        self.foodAppendPresenter.setOutput(foodAppendPresenterOutput: self)
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
        unitSelectButton.unitSelection()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func hideKeyboard() {
        self.view.endEditing(true)
        print("hide作動")
    }
    @IBAction func cancel(_ sender: Any) {
        self.foodAppendPresenter.didTapCancelButton()
    }

    @IBAction func preserve(_ sender: Any) {
        self.foodAppendPresenter.didTapPreserveButton(foodName: foodNameTextField.text, quantity: quantityTextField.text, unit: unitSelectButton.selectedUnit)
    }

}
extension FoodAppendViewController: UITextFieldDelegate {
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
    }
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
