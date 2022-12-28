//
//  SignUpViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/16.
//

import UIKit

final class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    private let signUpPresenter = SignUpPresenter.init(signUp: SignUp())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpPresenter.setOutput(signUpPresenterOutput: self)
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
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }

}
