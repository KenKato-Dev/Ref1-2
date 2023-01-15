//
//  signUp.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/11/27.

import Firebase
import FirebaseAuth
import Foundation

struct UserData {
    let userName: String
    let email: String
    let createdAt: Timestamp
    init(data: [String: Any]) {
        userName = data["userName"] as? String ?? ""
        email = data["email"] as? String ?? ""
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
    }
}

class UserService {

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
//    private (set) var errorMessage = ""

    func signIn(_ email: String, _ password: String, _ completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else {
                guard let user = authDataResult?.user else { return }
//                guard let uid = authDataResult?.user.uid else { return }
                completion(.success(user))
            }
        }
    }

    func checkSignInStatus(_ completion: @escaping (Bool) -> Void) {
        if auth.currentUser != nil && auth.currentUser!.isEmailVerified {
            completion(true)
        } else {
            completion(false)
        }
//        Auth.auth().addStateDidChangeListener { _, user in
//            if user == nil {
//                // 新規
//                completion(false)
//            } else {
//                // ログイン済み
//                completion(true)
//            }
//        }
    }

    func postUser(_ email: String,
                  _ userName: String?,
                  _ pass: String,
                  _ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            self.auth.createUser(withEmail: email, password: pass) { result, error in
                if let error = error {
                    completion(.failure(error))
                }
                print("manager認証に成功")
                //
                guard let userID = result?.user.uid else { return }
                guard let userName = userName else { return }
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

    func checkEmailUsed(_ email: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.fetchSignInMethods(forEmail: email) { method, error in
            if let error = error as NSError? {
                completion(.failure(error))
            } else {
                guard method != nil else {
                    completion(.success(true))
                    print("未使用のEmail")
                    return
                }
                completion(.success(false))
                print("既に使われているEmail")
            }
        }
    }

    func resetPasswordWithMail(_ mail: String) {
        self.auth.sendPasswordReset(withEmail: mail)
    }
    //
    func sendAuthEmail(_ completion:@escaping (Result<Bool, Error>) -> Void) {
        self.auth.currentUser?.sendEmailVerification { errorOrNil in // with: ActionCodeSettings,
            if let error = errorOrNil {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    //
    func checkMailValification(_ completion:@escaping (Result<Bool, Error>) -> Void) {
        self.auth.currentUser?.reload(completion: { errorOrNil in
            guard let currentUser = self.auth.currentUser else {return}
            if let error = errorOrNil {
                completion(.failure(error))
            } else {
                completion(.success(currentUser.isEmailVerified))
            }
        })
    }
}
