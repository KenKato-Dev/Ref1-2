//
//  SignUpViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/16.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    private let signUpPresenter = SignUpPresenter.init(signUp: SignUp())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpButton.addAction(.init(handler: { _ in
            self.signUpPresenter.didTapSignUpButton(
                self.emailTextField.text, self.userNameTextField.text, self.passwordTextField.text)
        }), for: .touchUpInside)
    }
}
extension SignUpViewController: UITextFieldDelegate {

}
extension SignUpViewController: SignUpPresenterOutput {
    func showEssential() {
            self.emailTextField.placeholder = "メールアドレスを入力してください"
            self.userNameTextField.placeholder = "ユーザー名を入力してください"
            self.passwordTextField.placeholder = "パスワード(7桁)を入力してください"
    }
    func presentErrorIfNeeded(_ alert: UIAlertController) {
        present(alert, animated: true) {
            print("エラー発生")
        }
    }

}
