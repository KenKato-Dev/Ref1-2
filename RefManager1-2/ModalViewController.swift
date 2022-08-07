//
//  ModalViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class ModalViewController: UIViewController, UITextFieldDelegate {
    private var baseArray = Food(location: .refrigerator, kind: .other, name: String(), quantity: String(), unit: UnitSelectButton.UnitMenu.initial, IDkey: UUID().uuidString, date: Date())

    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var methodSelectText: UILabel!
    @IBOutlet weak var refrigeratorButton: UIButton!
    @IBOutlet weak var freezerButton: UIButton!
    @IBOutlet weak var kindSelectText: UILabel!
    @IBOutlet weak var foodKindsStacks: UIStackView!
    @IBOutlet weak var topConstraintOfButtonsStack: NSLayoutConstraint!
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
    @IBOutlet weak var unitSelectButton: UnitSelectButton!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var preserveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameTextField.delegate = self
        quantityTextField.delegate = self
        let foodTextAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18.0),
            .foregroundColor: UIColor.gray
        ]
        let quantityTextAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.0),
            .foregroundColor: UIColor.gray
        ]
        foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: foodTextAttribute)
        quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: quantityTextAttribute)
        quantityTextField.keyboardType = .numberPad
//        textFieldShouldReturn(foodNameTextField)
        // 冷蔵ボタン
        refrigeratorButton.addAction(.init(handler: { _ in
            if ViewController.isEditMode == false {
                self.baseArray.location = .refrigerator
            } else {
                print("editの冷蔵ボタン")
            }
        }), for: .touchUpInside)
        // 冷凍ボタン
        freezerButton.addAction(.init(handler: { _ in
            if ViewController.isEditMode == false {
                self.baseArray.location = .freezer
            } else {
                print("editの冷凍ボタン")
            }
        }), for: .touchUpInside)
        meatButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .meat
        }), for: .touchUpInside)
        fishButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .fish
        }), for: .touchUpInside)
        vegetableAndFruitButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .vegetableAndFruit
        }), for: .touchUpInside)
        milkAndEggButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .milkAndEgg
        }), for: .touchUpInside)
        dishButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .dish
        }), for: .touchUpInside)
        drinkButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .drink
        }), for: .touchUpInside)
        seasoningButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .seasoning
        }), for: .touchUpInside)
        sweetButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .sweet
        }), for: .touchUpInside)
        othersButton.addAction(.init(handler: { _ in
            self.baseArray.kind = .other
        }), for: .touchUpInside)
//         Do any additional setup after loading the view.
        unitSelectButton.unitSelection()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    // viewDidLoad

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            quantityTextField.text = quantityTextField.text
//        foodNameTextField.text = foodNameTextField.text
//            self.view.endEditing(true)
//        }
    @objc func hideKeyboard() {
        self.view.endEditing(true)
        print("hide作動")
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func preserve(_ sender: Any) {
        if ViewController.isEditMode == false {
            baseArray.name = foodNameTextField.text!
            baseArray.quantity = String(Double(quantityTextField.text!) ?? 0.0) ?? "0.0"
            baseArray.unit = unitSelectButton.selectedUnit
//            FoodData.shared.add(baseArray)
            FoodData.shared.addtoDataBase(baseArray)
            dismiss(animated: true, completion: nil)
            print("オリジナルのFuncが動作")
        } else {
            print(ViewController.isEditMode)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

}
