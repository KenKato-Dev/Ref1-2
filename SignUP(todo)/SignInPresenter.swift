//
//  SignInPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import Foundation
import Firebase

protocol SignInPresenterOutput: AnyObject {
    func didTapWithoutNecessaryFields()
    func performSegue(uid: String)
    func presentErrorIfNeeded(_ errorOrNil: Error?)
}
class SignInPresenter {
    private let signUp: SignUp
    private weak var signInPresenterOutput: SignInPresenterOutput?
    private (set) var isFillOutNecessary = false
    init(signUp: SignUp) {
        self.signUp = signUp
    }
    func setOutput(signInPresenterOutput: SignInPresenterOutput?) {
        self.signInPresenterOutput = signInPresenterOutput
    }
    func didTapSignInButton(_ email: String, _ password: String) {
        self.signInPresenterOutput?.didTapWithoutNecessaryFields()
//        self.isFillOutNecessary = isFillOutNecessary
            signUp.signIn(email, password) { result in
                switch result {
                case let .success(uid):
                    self.isFillOutNecessary = true
                    self.signInPresenterOutput?.performSegue(uid: uid)
                case let .failure(error):
                    self.isFillOutNecessary = false
                    print(error)
                }
            }
    }
        }
