//
//  SignUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/15.
//

import Foundation
import Firebase

class SignUpPresenter {
    func didTapSignUPButton() {
        let email: String = ""
        let password: String = ""
        let userName: String = ""

        Auth.auth().createUser(withEmail: email, password: password) { [weak self]result, err in
            guard let self = self else {return}
            if let user = result?.user {
                let request = user.createProfileChangeRequest()
                request.displayName = userName
                request.commitChanges { [weak self]error in
                    guard let self = self else {return}
                    if error == nil {
                        user.sendEmailVerification { [weak self]error in
                            guard let self = self else {return}
                            if error == nil {
                                // 登録完了画面へ遷移する処理
                            }
                            // errorハンドル
                            self.showErrorIfNeeded(errorOrNil: error)
                        }
                    }
                    // errorハンドル
                    self.showErrorIfNeeded(errorOrNil: error)
                }
            }
            // errorハンドル
            self.showErrorIfNeeded(errorOrNil: err)
        }
    }
    func showErrorIfNeeded(errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // present
    }
}
