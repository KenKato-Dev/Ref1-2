//
//  SignInPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import Firebase
import Foundation

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
    private(set) var isFillOutNecessary = false
    private(set) var isDisableSegue = false
    init(userService: UserService) {
        self.userService = userService
    }

    func setOutput(signInPresenterOutput: SignInPresenterOutput?) {
        self.signInPresenterOutput = signInPresenterOutput
    }

    func hidePassword() {
        signInPresenterOutput?.isSequrePassEntry()
    }

    func hideWrongInputInInitial() {
        signInPresenterOutput?.showWorngInputIfNeeded(true)
    }

    func didTapSignInButton(_ email: String, _ password: String) {
        self.isDisableSegue = true
        signInPresenterOutput?.didTapWithoutNecessaryFields()
        signInPresenterOutput?.showLoadingSpin()
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
        signInPresenterOutput?.showAlertPassReset()
    }

    func sendResetMail(_ mail: String) {
        userService.resetPasswordWithMail(mail)
    }

    func performsegueIfAlreadySignIn() {
        userService.checkSignInStatus { isSignIn in
            if isSignIn && !self.isDisableSegue {
                self.signInPresenterOutput?.performSegue(uid: Auth.auth().currentUser!.uid)
            } else {
                print("サインイン履歴なし")
            }
        }
    }
//    static func performsegueIfAlreadySignIn() {
//        UserService.shared.checkSignInStatus { isSignIn in
//            if isSignIn {
//                SignInViewController().performSegue(uid: Auth.auth().currentUser!.uid)
//            } else {
//                print("サインイン履歴なし")
//            }
//        }
//    }
    func resetIsFillOutNecessary() {
        isFillOutNecessary = false
    }
    func resetisDisableSgue() {
        self.isDisableSegue = false
    }
}
