//
//  SignInPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import Foundation

protocol SignInPresenterOutput: AnyObject {
    func didTapWithoutNecessaryFields()
    func presentErrorIfNeeded(_ errorOrNil: Error?)

}
class SignInPresenter {
    private let signUp: SignUp
    private weak var signInPresenterOutput: SignInPresenterOutput?
    init(signUp: SignUp) {
        self.signUp = signUp
    }
    func setOutput(signInPresenterOutput: SignInPresenterOutput?) {
        self.signInPresenterOutput = signInPresenterOutput
    }
    func didTapSignInButton() {

    }
}
