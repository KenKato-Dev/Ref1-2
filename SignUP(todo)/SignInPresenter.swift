//
//  SignInPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import Foundation
import Firebase

protocol SignInPresenterOutput: AnyObject {
    func isSequrePassEntry()
    func didTapWithoutNecessaryFields()
    func performSegue(uid: String)
    func resetContetntsOfTextField()
    func showWorngInputIfNeeded(_ isHidden: Bool)
    func showAlertPassReset()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
}
final class SignInPresenter {
    private let signUp: SignUp
    private weak var signInPresenterOutput: SignInPresenterOutput?
    private (set) var isFillOutNecessary = false
    init(signUp: SignUp) {
        self.signUp = signUp
    }
    func setOutput(signInPresenterOutput: SignInPresenterOutput?) {
        self.signInPresenterOutput = signInPresenterOutput
    }
    func hidePassword() {
        self.signInPresenterOutput?.isSequrePassEntry()
    }
    func hideWrongInputInInitial() {
        self.signInPresenterOutput?.showWorngInputIfNeeded(true)
    }
    func didTapSignInButton(_ email: String, _ password: String) {
        self.signInPresenterOutput?.didTapWithoutNecessaryFields()
//        self.isFillOutNecessary = isFillOutNecessary
            signUp.signIn(email, password) { result in
                switch result {
                case let .success(uid):
                    self.isFillOutNecessary = true
                    self.signInPresenterOutput?.performSegue(uid: uid)
                    self.signInPresenterOutput?.resetContetntsOfTextField()
                    self.signInPresenterOutput?.showWorngInputIfNeeded(self.isFillOutNecessary)
                case let .failure(error):
                    self.isFillOutNecessary = false
                    self.signInPresenterOutput?.showWorngInputIfNeeded(self.isFillOutNecessary)
                    print(error)
                }
            }
    }
    func didTapResetPassButton() {
        self.signInPresenterOutput?.showAlertPassReset()
    }
    func sendResetMail(_ mail: String) {
        signUp.resetPasswordWithMail(mail)
    }
    func resetIsFillOutNecessary() {
        self.isFillOutNecessary = false
    }
        }
