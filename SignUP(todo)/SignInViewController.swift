//
//  SignInViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var mainLabelText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var showSignUpViewButton: UIButton!
    private let signInPresenter = SignInPresenter(signUp: SignUp())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signInPresenter.setOutput(signInPresenterOutput: self)
        self.signInButton.addAction(.init(handler: { _ in
            guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {return}
            self.signInPresenter.didTapSignInButton(email, password)
        }), for: .touchUpInside)
    }
    // performsegueと連動
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toFoodListView" {
//            let foodListView = segue.destination as? FoodListViewController
//            foodListView?.receivedUIDFromSignInVC = "\(sender!)"
//        }
//    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toFoodListView" && self.signInPresenter.isFillOutNecessary {
            return true
        } else {
            return false
        }
    }
}
extension SignInViewController: UITextFieldDelegate {

}
extension SignInViewController: SignInPresenterOutput {
    func didTapWithoutNecessaryFields() {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            emailTextField.placeholder = "メールアドレスを入力してください"
            passwordTextField.placeholder = "パスワードを入力してください"
        }
    }
    func performSegue(uid: String) {
//        if self.shouldPerformSegue(withIdentifier: "toFoodListView", sender: uid) {
//            performSegue(uid: uid)
//        }
        self.performSegue(withIdentifier: "toFoodListView", sender: uid)
    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
}
