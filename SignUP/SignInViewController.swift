//
//  SignInViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import UIKit
import Firebase

final class SignInViewController: UIViewController {

    @IBOutlet weak var mainLabelText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var wrongInputLabel: UILabel!
    @IBOutlet weak var showSignUpViewButton: UIButton!
    @IBOutlet weak var resetPassButton: UIButton!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let signInPresenter = SignInPresenter(userService: UserService())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signInPresenter.setOutput(signInPresenterOutput: self)
        self.signInPresenter.performsegueIfAlreadySignIn()
        self.signInPresenter.hideWrongInputInInitial()
        self.signInPresenter.hidePassword()
        self.signInButton.addAction(.init(handler: { _ in
            guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {return}
            self.signInPresenter.didTapSignInButton(email, password)
        }), for: .touchUpInside)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        self.resetPassButton.addAction(.init(handler: { _ in
            self.signInPresenter.didTapResetPassButton()
        }), for: .touchUpInside)
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toFoodListView" && self.signInPresenter.isFillOutNecessary {
            return true
        } else if identifier == "toSignUpVC"{
            return true
        } else {
            return false
        }
    }
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}
extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension SignInViewController: SignInPresenterOutput {
    func isSequrePassEntry() {
        self.passwordTextField.isSecureTextEntry = true
    }
    func didTapWithoutNecessaryFields() {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            emailTextField.placeholder = "メールアドレスを入力してください"
            passwordTextField.placeholder = "パスワードを入力してください"
        }
    }
    func showWorngInputIfNeeded(_ isHidden: Bool) {
        self.wrongInputLabel.isHidden = isHidden
    }
    func resetContetntsOfTextField() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.signInPresenter.resetIsFillOutNecessary()
    }
    func performSegue(uid: String) {
        self.performSegue(withIdentifier: "toFoodListView", sender: uid)
    }
    func showAlertPassReset() {
        // 削除するかどうかアラート
        var textFieldOfAlert = UITextField()
        textFieldOfAlert.delegate = self
        let alert = UIAlertController(title: "パスワードをリセットします", message: "パスワード再設定メールを送りします", preferredStyle: .alert)
        let sendEmail = UIAlertAction(title: "送信", style: .default, handler: { _ in
            guard let textInTextField = textFieldOfAlert.text else {return}
            self.signInPresenter.sendResetMail(textInTextField)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .destructive)

        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.addAction(.init(handler: { _ in
                guard let textInTextField = textField.text else {return}
                if textInTextField.isEmpty {
                    textField.attributedPlaceholder =
                    NSAttributedString(
                        string: "メールアドレスを入力してください",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
                    )
                    sendEmail.isEnabled = false
                } else {
                    textFieldOfAlert = textField
                    sendEmail.isEnabled = true
                }
            }), for: .allEditingEvents)
            textField.resignFirstResponder()
        })
        alert.addAction(sendEmail)
        alert.addAction(cancel)

        present(alert, animated: true)
    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
    func checkSignInStatus(_ isSignIn: Bool) -> UIViewController {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows.filter({$0.isKeyWindow}).first

        let rootVC = UIApplication.shared.keyWindow

        if isSignIn {
            let signInVC = SignInViewController()
            return signInVC
        } else {
            let foodListVC = FoodListViewController()
            return foodListVC
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
