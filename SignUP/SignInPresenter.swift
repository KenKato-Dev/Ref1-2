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
    func presentErrorIfNeeded(_ errorMessage: String)
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
        if Auth.auth().currentUser == nil {
            self.signInPresenterOutput?.presentErrorIfNeeded("ユーザー登録を確認できません")
            self.signInPresenterOutput?.hideIndicator(true)
        }
        if Auth.auth().currentUser!.isEmailVerified {
            userService.signIn(email, password) { result in
                self.signInPresenterOutput?.hideIndicator(true)
                switch result {
                case let .success(uid):
                    self.isFillOutNecessary = true
                    self.signInPresenterOutput?.performSegue(uid: uid)
                    self.signInPresenterOutput?.resetContetntsOfTextField()
                case let .failure(error):
                    self.isFillOutNecessary = false
                    if let error = error as NSError? {
                        self.signInPresenterOutput?.presentErrorIfNeeded(self.manageSiginInErrorMessage(error))
                        print(error)
                        self.signInPresenterOutput?.hideIndicator(true)
                    }
                }
            }
        } else {
            self.signInPresenterOutput?.presentErrorIfNeeded("メール認証を確認できません")
            self.signInPresenterOutput?.hideIndicator(true)
        }
        //
    }
    func reloadUser() {
        Auth.auth().currentUser?.reload()
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
    func resetIsFillOutNecessary() {
        isFillOutNecessary = false
    }
    func resetisDisableSgue() {
        self.isDisableSegue = false
    }
    func manageSiginInErrorMessage(_ error: NSError) -> String {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .invalidEmail:
                    print("メールアドレスの形式が違います")
                    return "メールアドレスの形式が違います"
                case .emailAlreadyInUse:
                    print("このメールアドレスはすでに使われています")
                    return "このメールアドレスはすでに使われています"
                case .weakPassword:
                    print("パスワードが簡単すぎます")
                    return "パスワードが簡単すぎます"
                case .userNotFound, .wrongPassword:
                    print("メールアドレス、またはパスワードが間違えてます")
                    return "メールアドレス、またはパスワードが間違えてます"
                case .userDisabled:
                    print("このユーザーアカウントは無効化されています")
                    return "このユーザーアカウントは無効化されています"
                default:
                    print("良きせぬエラーが発生しました\nしばらくお待ちください")
                    return "良きせぬエラーが発生しました\nしばらくお待ちください"
                }
    }}
