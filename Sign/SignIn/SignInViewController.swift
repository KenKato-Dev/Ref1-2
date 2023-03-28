//
//  SignInViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import Firebase
import GoogleMobileAds
import UIKit

final class SignInViewController: UIViewController {
    @IBOutlet var mainLabelText: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var wrongInputLabel: UILabel!
    @IBOutlet var pushSignUpViewButton: UIButton!
    @IBOutlet var trialButton: UIButton!
    @IBOutlet var resetPassButton: UIButton!
    @IBOutlet private var bannerView: GADBannerView!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let signInPresenter = SignInPresenter(userService: UserService())
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        signInPresenter.setOutput(signInPresenterOutput: self)
        signInPresenter.displayBanner()
        signInPresenter.performsegueIfAlreadySignIn()
        signInPresenter.hideWrongInputInInitial()
        signInPresenter.hidePassword()
        signInPresenter.reloadUser()
        pushSignUpViewButton.addAction(.init(handler: { _ in
            self.signInPresenter.didTapPushSignInButton()
        }), for: .touchUpInside)
        signInButton.addAction(.init(handler: { _ in
            guard let email = self.emailTextField.text, let password
                = self.passwordTextField.text else { return }
            self.signInPresenter.didTapSignInButton(email, password)
        }), for: .touchUpInside)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        resetPassButton.addAction(.init(handler: { _ in
            self.signInPresenter.didTapResetPassButton()
        }), for: .touchUpInside)
        trialButton.addAction(.init(handler: { _ in
            self.signInPresenter.didTapTrialButton()
        }), for: .touchUpInside)
    }

    // performsegueの動作を制御
    override func shouldPerformSegue(withIdentifier _: String, sender _: Any?) -> Bool {
//        if identifier == "toFoodListView", signInPresenter.isFillOutNecessary {
//            return true
//        } else
//        if identifier == "toSignUpVC" {
//            return true
//        } else {
//            return false
//        }
        return true
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignInViewController: SignInPresenterOutput {
    // 入力したパスワードを●に変更
    func isSequrePassEntry() {
        passwordTextField.isSecureTextEntry = true
    }

    // 必要事項を入力していなければ下記を表示
    func didTapWithoutNecessaryFields() {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            emailTextField.placeholder = "メールアドレスを入力してください"
            passwordTextField.placeholder = "パスワードを入力してください"
        }
    }

    // textFieldへの記載が誤っている場合Boolにて表示
    func showWorngInputIfNeeded(_ isHidden: Bool) {
        if !isHidden {
            wrongInputLabel.textColor = .red
        }
    }

    // 画面遷移後テキストフィールドの記述を削除しShouldperformSegueの条件をリセット
    func resetContetntsOfTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
        signInPresenter.resetIsFillOutNecessary()
        signInPresenter.resetisDisableSgue()
        wrongInputLabel.textColor = .clear
    }

    func performSegue(uid _: String) {
//        performSegue(withIdentifier: "toFoodListView", sender: uid)
    }

    func showAlertPassReset() {
        // 削除するかどうかアラート
        var textFieldOfAlert = UITextField()
        textFieldOfAlert.delegate = self
        let alert = UIAlertController(title: "パスワードをリセットします", message: "パスワード再設定メールを送りします", preferredStyle: .alert)
        let sendEmail = UIAlertAction(title: "送信", style: .default, handler: { _ in
            guard let textInTextField = textFieldOfAlert.text else { return }
            self.signInPresenter.sendResetMail(textInTextField)
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .destructive)

        alert.addTextField(configurationHandler: { textField in
            textField.addAction(.init(handler: { _ in
                guard let textInTextField = textField.text else { return }
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

    func showErrorMessageIfNeeded(_ errorMessage: String) {
//        let message = errorMessage
        let alart = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {}
    }

    // 試作
//    static func checkSignInStatus(_ isSignIn: Bool) -> UIViewController {
//        if isSignIn {
//            let signInVC = SignInViewController()
//            return signInVC
//        } else {
//            let foodListVC = FoodListViewController()
//            return foodListVC
//        }
//    }

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

    func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }

    // GoogleAd
    func setUpAdBanner() {
        // 実装テスト用ID
        bannerView.adUnitID = env["adUnitIDForSignIn"]!
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.isHidden = false
    }

    func pushFoodView() {
        let foodListView = UIStoryboard(
            name: "MainTab",
//            name: "FoodList",
            bundle: nil
        )
            .instantiateViewController(withIdentifier: "MainTab") as! MainTabViewController
//        .instantiateViewController(withIdentifier: "FoodListViewController") as! FoodListViewController
//        present(foodListView, animated: true)
        navigationController?.pushViewController(foodListView, animated: true)

    }

    func pushSignUpView() {
        let signUpView = UIStoryboard(
            name: "SignUp",
            bundle: nil
        )
            .instantiateViewController(withIdentifier: "SignUpView") as! SignUpViewController
        navigationController?.pushViewController(signUpView, animated: true)
    }
}
