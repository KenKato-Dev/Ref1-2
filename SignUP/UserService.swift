//
//  signUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.

import Foundation
import Firebase
import FirebaseAuth

struct UserData {
    let userName: String
    let email: String
    let createdAt: Timestamp
    init(data: [String: Any]) {
        self.userName = data["userName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
    }
}
class UserService {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var alart = UIAlertController(title: nil, message: "エラー発生:\(Error?.self)", preferredStyle: .alert)

    func signIn(_ email: String, _ password: String, _ completion:@escaping (Result<String, Error>) -> Void) {
        self.auth.signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else {
                guard let uid = authDataResult?.user.uid else {return}
                completion(.success(uid))
            }
        }
    }
     func checkSignInStatus(_ completion:@escaping (Bool) -> Void) {
        Auth.auth().addStateDidChangeListener { _, user in
            if user == nil {
                // 新規
                completion(false)
            } else {
                // ログイン済み
                completion(true)
            }
        }
    }
    func postUser(_ email: String,
                  _ userName: String?,
                  _ pass: String,
                  _ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            self.auth.createUser(withEmail: email, password: pass) { result, err in
            if let err = err {
                completion(.failure(err))
                print("manager認証にエラー発生:\(err)")
                return
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
                    completion(.failure(err))
                }
                completion(.success(()))
                print("manager情報の保存に成功")
            }
        }
        }
    }
    func checkEmailUsed(_ email: String, _ completion: @escaping(Result<Bool, Error>) -> Void) {
        self.auth.fetchSignInMethods(forEmail: email) { method, error in
            if let error = error {
                completion(.failure(error))
                print("checkEmailUsedに失敗")
                return
            }

            guard method != nil else {
                completion(.success(true))
                print("未使用のEmail")
                return
            }
            completion(.success(false))
            print("既に使われているEmail")
        }
    }
    func resetPasswordWithMail(_ mail: String) {
        self.auth.sendPasswordReset(withEmail: mail)
    }

}
