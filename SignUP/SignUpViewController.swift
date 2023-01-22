//
//  SignUpViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/16.
//

import UIKit

final class SignUpViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var wrongInputLabel: UILabel!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let signUpPresenter = SignUpPresenter(userService: UserService())
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        signUpPresenter.setOutput(signUpPresenterOutput: self)
        signUpPresenter.hidePassword()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        signUpButton.addAction(.init(handler: { _ in
            self.signUpPresenter
                .didTapSignUpButton(
                    self.emailTextField.text,
                    self.userNameTextField.text,
                    self.passwordTextField.text
                )
        }), for: .touchUpInside)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController: SignUpPresenterOutput {
    func isSequrePassEntry() {
        passwordTextField.isSecureTextEntry = true
    }

    func showEssential() {
        emailTextField.placeholder = "メールアドレスを入力してください"
        userNameTextField.placeholder = "ユーザー名を入力してください"
        passwordTextField.placeholder = "パスワード(7桁以上)を入力してください"
        wrongInputLabel.tintColor = .red
    }

    func showUsedEmail() {
        wrongInputLabel.text = "そのメールアドレスは既に使われています"
        wrongInputLabel.textColor = .red
    }

    func presentErrorIfNeeded(_ errorMessage: String) {
        let alart = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {}
    }

    func showLoadingSpin() {
        indicatorBackView = UIView(frame: view.bounds)
        indicatorBackView.backgroundColor = .white
        indicatorBackView.alpha = 0.5

        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        indicatorBackView.addSubview(activityIndicator)
        view.addSubview(indicatorBackView)
        activityIndicator.startAnimating()
    }

    func dismiss() {
        dismiss()
    }

    func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }
}
