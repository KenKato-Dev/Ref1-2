//
//  SignInViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var showSignUpViewButton: UIButton!
    private let signInPresenter = SignInPresenter(signUp: SignUp())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signInPresenter.setOutput(signInPresenterOutput: self)
    }
}
extension SignInViewController: UITextFieldDelegate {

}
extension SignInViewController: SignInPresenterOutput {
    func didTapWithoutNecessaryFields() {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {

        }
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
