//
//  signUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.
//
// 参考：https://tomo-bb-aki0117115.hatenablog.com/entry/2021/01/19/021832

import Foundation
import Firebase
import FirebaseAuth

struct User {
    let userName: String
    let email: String
    let createdAt: Timestamp
    init(data: [String: Any]) {
        self.userName = data["userName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
    }
}
class SignUp {
    private let db = Firestore.firestore()
    private var alart = UIAlertController(title: nil, message: "エラー発生:\(Error?.self)", preferredStyle: .alert)
//    private var user = User(data: [
//        "email": "",
//        "userName": "",
//        "createdAt": Timestamp()
//    ])
    func postUser(_ email: String, _ userName: String?, _ pass: String) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
        Auth.auth().createUser(withEmail: email, password: pass) { result, err in
            if let err = err {
                print("manager認証にエラー発生:\(err)")
                self.addAlartActionIfNeeded(self.alart, err)
            }
            print("manager認証に成功")
            //
            guard let userID = result?.user.uid else {return}
            guard let userName = userName else {return}
            let documentData: [String: Any] = [
                "email": email,
                "userName": userName,
                "createdAt": Timestamp()
            ]
            self.db.collection("Users").document(userID).setData(documentData) { err in
                if let err = err {
                    print("manager情報保存に失敗：\(err)")
                    self.addAlartActionIfNeeded(self.alart, err)
                    return
                }
                print("manager情報の保存に成功")
            }
        }
        }
    }
//    func fetchUserInfo() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        self.db.collection("Users").document(uid).getDocument { documentSnapshot, error in
//            if let error = error {
//                print("ユーザー情報取得に失敗:\(error)")
//                self.addAlartActionIfNeeded(self.alart, error)
//                return
//            }
//            guard let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() else {return}
//            let user = User(data: data)
//            self.user = user
//        }
//    }
    func fetchUserInfo(_ completion: @escaping (Result<User, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            self.db.collection("Users").document(uid).getDocument { documentSnapshot, error in
                if let error = error {
                    print("ユーザー情報取得に失敗:\(error)")
                    completion(.failure(error))
                    return
                }
                guard let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() else {return}
                let user = User(data: data)
//                self.user = user
                completion(.success(user))
            }
        }
    }
    func addAlartActionIfNeeded(_ alart: UIAlertController, _ errorOrNil: Error?) {
//        guard let error = errorOrNil else { return }
//        let message = "エラー発生:\(error)"
//
//        alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        

    }
}
//    func didTapSignUPButton() {
//        let email: String = ""
//        let password: String = ""
//        let userName: String = ""
//
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self]result, err in
//            guard let self = self else {return}
//            if let user = result?.user {
//                let request = user.createProfileChangeRequest()
//                request.displayName = userName
//                request.commitChanges { [weak self]error in
//                    guard let self = self else {return}
//                    if error == nil {
//                        user.sendEmailVerification { [weak self]error in
//                            guard let self = self else {return}
//                            if error == nil {
//                                // 登録完了画面へ遷移する処理
//                            }
//                            // errorハンドル
//                            self.showErrorIfNeeded(errorOrNil: error)
//                        }
//                    }
//                    // errorハンドル
//                    self.showErrorIfNeeded(errorOrNil: error)
//                }
//            }
//            // errorハンドル
//            self.showErrorIfNeeded(errorOrNil: err)
//        }
//    }
