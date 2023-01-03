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
    func showLoadingSpin()
    func hideIndicator(_ isHidden: Bool)
}
final class SignInPresenter {
    private let userService: UserService
    private weak var signInPresenterOutput: SignInPresenterOutput?
    private (set) var isFillOutNecessary = false
    init(userService: UserService) {
        self.userService = userService
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
        self.signInPresenterOutput?.showLoadingSpin()
            userService.signIn(email, password) { result in
                self.signInPresenterOutput?.hideIndicator(true)
                switch result {
                case let .success(uid):
                    self.isFillOutNecessary = true
                    self.signInPresenterOutput?.performSegue(uid: uid)
                    self.signInPresenterOutput?.resetContetntsOfTextField()
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
        userService.resetPasswordWithMail(mail)
    }
    func performsegueIfAlreadySignIn() {
        userService.checkSignInStatus { isSignIn in
            if isSignIn {
                self.signInPresenterOutput?.performSegue(uid: Auth.auth().currentUser!.uid)
            } else {
                print("サインイン履歴なし")
            }
        }
    }
    func resetIsFillOutNecessary() {
        self.isFillOutNecessary = false
    }
        }
