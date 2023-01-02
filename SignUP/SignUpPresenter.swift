//
//  SignUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/15.
//

import Foundation
import Firebase

protocol SignUpPresenterOutput: AnyObject {
    func isSequrePassEntry()
    func showEssential()
    func showUsedEmail()
    func dismiss()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
}
final class SignUpPresenter {
    private let userService: UserService
    private weak var signUpPresenterOutput: SignUpPresenterOutput?
    init(userService: UserService) {
        self.userService = userService
    }
    func setOutput(signUpPresenterOutput: SignUpPresenterOutput?) {
        self.signUpPresenterOutput = signUpPresenterOutput
    }
    func hidePassword() {
        self.signUpPresenterOutput?.isSequrePassEntry()
    }
    func didTapSignUpButton(_ email: String?, _ userName: String?, _ pass: String?) {
        guard let email = email, let userName = userName, let pass = pass else {return}
        if email.isEmpty || pass.count < 6 || userName.isEmpty {
            self.signUpPresenterOutput?.showEssential()
        } else {
            self.userService.checkEmailUsed(email) { result in
                switch result {
                case var .success(isUnusing):
                    if isUnusing {
                        self.userService.postUser(email, userName, pass) { result in
                            switch result {
                            case .success:
                                print("ユーザー登録に成功")
                                self.signUpPresenterOutput?.dismiss()
                            case let .failure(error):
                                self.signUpPresenterOutput?.presentErrorIfNeeded(error)
                            }
                        }
                    } else {
                        // すでに使われているEmailである旨を伝える
                        self.signUpPresenterOutput?.showUsedEmail()
                        print("このメルアドは利用済み")
                    }
                case let .failure(error):
                    self.signUpPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }

    }
}
