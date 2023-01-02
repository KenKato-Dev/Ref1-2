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
    @IBOutlet weak var wrongInputLabel: UILabel!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let signUpPresenter = SignUpPresenter.init(userService: UserService())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpPresenter.setOutput(signUpPresenterOutput: self)
        self.signUpPresenter.hidePassword()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        self.signUpButton.addAction(.init(handler: { _ in
            self.signUpPresenter
                .didTapSignUpButton(
                    self.emailTextField.text,
                    self.userNameTextField.text,
                    self.passwordTextField.text)
        }), for: .touchUpInside)
    }
    @objc func hideKeyboard() {
        self.view.endEditing(true)
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
        self.passwordTextField.isSecureTextEntry = true
    }
    func showEssential() {
            self.emailTextField.placeholder = "メールアドレスを入力してください"
            self.userNameTextField.placeholder = "ユーザー名を入力してください"
            self.passwordTextField.placeholder = "パスワード(7桁以上)を入力してください"
        self.wrongInputLabel.tintColor = .red
    }
    func showUsedEmail() {
        self.wrongInputLabel.text = "そのメールアドレスは既に使われています"
        self.wrongInputLabel.textColor = .red
    }
    func performSegue(uid: String) {
        self.performSegue(withIdentifier: "toFoodListViewDirectly", sender: uid)
    }
    func dismiss() {
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
    func showLoadingSpin() {
        self.indicatorBackView = UIView(frame: self.view.bounds)
        self.indicatorBackView.backgroundColor = .white
        self.indicatorBackView.alpha = 0.5

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .large
        self.activityIndicator.color = .gray
        self.activityIndicator.center = self.view.center
        self.indicatorBackView.addSubview(activityIndicator)
        self.view.addSubview(indicatorBackView)
        self.activityIndicator.startAnimating()
    }
    func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
        }
}
