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

    func signIn(_ email: String, _ password: String, _ completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else {
                guard let user = authDataResult?.user else { return }
                completion(.success(user))
            }
        }
    }
    func sigInAsTrial(_ completion: @escaping (Result<User, Error>) -> Void) {
        auth.signInAnonymously {  [weak self] authDataResult, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else {
                guard let user = authDataResult?.user else { return }
                completion(.success(user))
            }
        }
    }
    func checkSignInStatus(_ completion: @escaping (Bool) -> Void) {
        if auth.currentUser != nil, auth.currentUser!.isEmailVerified {
            completion(true)
        } else {
            completion(false)
        }
    }
    // お試しユーザーの場合はマージで情報上書き対応
    func postUser(_ email: String,
                  _ userName: String?,
                  _ pass: String,
                  _ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {

            if let user = self.auth.currentUser, user.isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: pass)
                user.link(with: credential) { result, errorOrNil in
                    if let error = errorOrNil {
                        completion(.failure(error))
                    }
                    print("認証成功\(result?.user.uid)")
                    print(self.auth.currentUser?.isEmailVerified)

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

            } else {
                self.auth.createUser(withEmail: email, password: pass) { result, error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    print("manager認証に成功")

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
                } // createUser
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
        auth.sendPasswordReset(withEmail: mail)
    }

    //
    func sendAuthEmail(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.currentUser?.sendEmailVerification { errorOrNil in
            if let error = errorOrNil {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    //
    func checkMailValification(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.currentUser?.reload(completion: { errorOrNil in
            guard let currentUser = self.auth.currentUser else { return }
            if let error = errorOrNil {
                completion(.failure(error))
            } else {
                completion(.success(currentUser.isEmailVerified))
            }
        })
    }
}
