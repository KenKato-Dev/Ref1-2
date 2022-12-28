//
//  SignUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/15.
//

import Foundation
import Firebase

protocol SignUpPresenterOutput: AnyObject {
    func showEssential()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
}
final class SignUpPresenter {
    private let signUp: SignUp
    private weak var signUpPresenterOutput: SignUpPresenterOutput?
    init(signUp: SignUp) {
        self.signUp = signUp
    }
    func setOutput(signUpPresenterOutput: SignUpPresenterOutput?) {
        self.signUpPresenterOutput = signUpPresenterOutput
    }
    func didTapSignUpButton(_ email: String?, _ userName: String?, _ pass: String?) {
        guard let email = email, let userName = userName, let pass = pass else {return}
        if email.isEmpty || pass.isEmpty || pass.count < 6 || userName.isEmpty {
            self.signUpPresenterOutput?.showEssential()
        } else {
            self.signUp.postUser(email, userName, pass) { result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    self.signUpPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }

    }
}
