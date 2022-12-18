//
//  ModalViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

    // FoodAppendViewのVC
class FoodAppendViewController: UIViewController {
    private let foodAppendPresenter = FoodAppendPresenter(foodData: FoodData())
    @IBOutlet var foodNameTextField: UITextField!
    @IBOutlet var nameTextHeightconstraint: NSLayoutConstraint!
    @IBOutlet var methodSelectText: UILabel!
    @IBOutlet var refrigeratorButton: UIButton!
    @IBOutlet var freezerButton: UIButton!
    @IBOutlet weak var locationButtonsStack: UIStackView!
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
        // 各種ボタン操作
        refrigeratorButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTaplocationButton(location: .refrigerator)
        }), for: .touchUpInside)
        freezerButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTaplocationButton(location: .freezer)
        }), for: .touchUpInside)
        meatButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .meat, self.meatButton)
        }), for: .touchUpInside)
        fishButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .fish, self.fishButton)
        }), for: .touchUpInside)
        vegetableAndFruitButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .vegetableAndFruit, self.vegetableAndFruitButton)
        }), for: .touchUpInside)
        milkAndEggButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .milkAndEgg, self.milkAndEggButton)
        }), for: .touchUpInside)
        dishButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .dish, self.dishButton)
        }), for: .touchUpInside)
        drinkButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .drink, self.drinkButton)
        }), for: .touchUpInside)
        seasoningButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .seasoning, self.seasoningButton)
        }), for: .touchUpInside)
        sweetButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .sweet, self.sweetButton)
        }), for: .touchUpInside)
        othersButton.addAction(.init(handler: { _ in
            self.foodAppendPresenter.didTapKindButton(kind: .other, self.othersButton)
        }), for: .touchUpInside)
        unitSelectButton.selectingUnit()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    // キーボードを下げる処理
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    // キャンセルボタンの処理
    @IBAction func cancel(_: Any) {
        foodAppendPresenter.didTapCancelButton()
    }
    // 保存ボタンの処理
    @IBAction func preserve(_: Any) {
        foodAppendPresenter.didTapPreserveButton(foodName: foodNameTextField.text, quantity: quantityTextField.text, unit: unitSelectButton.selectedUnit)
    }
}
// enterでキーボードを下げる処理
extension FoodAppendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// Outputの中身を注入
extension FoodAppendViewController: FoodAppendPresenterOutput {
    // placeholderとキーボードの種類を指定
    func settingTextfield() {
        foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        quantityTextField.keyboardType = .numberPad
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    // dismiss処理
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    // テキストフィールドの入力内容、選択ボタンの種類で条件付けしプレースホルダーの表示とボタンテキスト色を変更
    func didTapPreserveButtonWithoutEssential() {
        if self.foodNameTextField.text!.isEmpty {
            self.foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

    }
        if self.quantityTextField.text!.isEmpty {
        self.quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        } else if Int(self.quantityTextField.text!) == nil {
            self.quantityTextField.text = ""
            self.quantityTextField.attributedPlaceholder = NSAttributedString(string: "数字を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        if self.unitSelectButton.selectedUnit == .initial {
            unitSelectButton.tintColor = .red
        }
    }
    // エラーハンドル、内容を表示
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
    //
    func presentMessageIfNeeded2(_ errorOrNil: Error?, _ comment: String) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }

    //
    func resetButtonsImage() {
        self.meatButton.setImage(UIImage(named: "meatButton"), for: .normal)
        self.meatButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.fishButton.setImage(UIImage(named: "fishButton"), for: .normal)
        self.fishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.vegetableAndFruitButton.setImage(UIImage(named: "vegetableAndFruitButton"), for: .normal)
        self.vegetableAndFruitButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.milkAndEggButton.setImage(UIImage(named: "milkAndEggButton"), for: .normal)
        self.milkAndEggButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.dishButton.setImage(UIImage(named: "dishButton"), for: .normal)
        self.dishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.drinkButton.setImage(UIImage(named: "drinkButton"), for: .normal)
        self.drinkButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.seasoningButton.setImage(UIImage(named: "seasoningButton"), for: .normal)
        self.seasoningButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.sweetButton.setImage(UIImage(named: "sweetButton"), for: .normal)
        self.sweetButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.othersButton.setImage(UIImage(named: "otherButton"), for: .normal)
        self.othersButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    func animateButton(_ location: Food.Location) {
        if location == .refrigerator {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        if location == .freezer {
            freezerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            freezerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
