//
//  SignUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/15.
//

import Firebase
import Foundation

protocol SignUpPresenterOutput: AnyObject {
    func isSequrePassEntry()
    func showEssential()
    func showUsedEmail()
    func performSegue(uid: String)
    func presentErrorIfNeeded(_ errorMessage: String)
    func showLoadingSpin()
    func hideIndicator(_ isHidden: Bool)
}

final class SignUpPresenter {
    private let userService: UserService
    private(set) var isDisableSegue = false
    private weak var signUpPresenterOutput: SignUpPresenterOutput?
    init(userService: UserService) {
        self.userService = userService
    }

    func setOutput(signUpPresenterOutput: SignUpPresenterOutput?) {
        self.signUpPresenterOutput = signUpPresenterOutput
    }

    func hidePassword() {
        signUpPresenterOutput?.isSequrePassEntry()
    }

    func didTapSignUpButton(_ email: String?, _ userName: String?, _ pass: String?) {
        guard let email = email, let userName = userName, let pass = pass else { return }
        if email.isEmpty || pass.count < 6 || userName.isEmpty {
            signUpPresenterOutput?.showEssential()
        } else {
            signUpPresenterOutput?.showLoadingSpin()
            DispatchQueue.main.async {
                self.userService.checkEmailUsed(email) { result in
                    switch result {
                    case let .success(isUnusing):
                        if isUnusing {
                            self.userService.postUser(email, userName, pass) { result in
                                self.signUpPresenterOutput?.hideIndicator(true)
                                switch result {
                                case .success:
                                    print("ユーザー登録に成功")
                                    self.signUpPresenterOutput?.performSegue(uid: Auth.auth().currentUser!.uid)
                                    self.isDisableSegue = true

                                case let .failure(error):
                                    if let error = error as NSError? {
                                        self.signUpPresenterOutput?.presentErrorIfNeeded(self.manageAuthErrorMessage(error))
                                        self.signUpPresenterOutput?.hideIndicator(true)
                                    }
                                }
                            }
                        } else {
                            // すでに使われているEmailである旨を伝える
                            self.signUpPresenterOutput?.showUsedEmail()
                            print("このメルアドは利用済み")
                        }
                    case let .failure(error):
                        if let error = error as NSError? {
                            print(error)
                            self.signUpPresenterOutput?.presentErrorIfNeeded(self.manageAuthErrorMessage(error))
                            self.signUpPresenterOutput?.hideIndicator(true)
                        }
                    }
                }
            }
        }
    }
    func manageAuthErrorMessage(_ error: NSError) -> String {
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
    }
}
