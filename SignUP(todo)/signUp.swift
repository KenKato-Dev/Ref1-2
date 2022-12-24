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
class SignUp {
    private let db = Firestore.firestore()
    private var alart = UIAlertController(title: nil, message: "エラー発生:\(Error?.self)", preferredStyle: .alert)

    func signIn(_ email: String, _ password: String, _ completion:@escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            if let error = error {
                print(error)
                completion(.failure(error))
            } else {
                guard let uid = authDataResult?.user.uid else {return}
                completion(.success(uid))
            }
        }
    }
    func postUser(_ email: String, _ userName: String?, _ pass: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
        Auth.auth().createUser(withEmail: email, password: pass) { result, err in
            if let err = err {
                completion(.failure(err))
                print("manager認証にエラー発生:\(err)")
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
    func fetchUserInfo(_ completion: @escaping (Result<UserData, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            self.db.collection("Users").document(uid).getDocument { documentSnapshot, error in
                if let error = error {
                    print("ユーザー情報取得に失敗:\(error)")
                    completion(.failure(error))
                    return
                }
                guard let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() else {return}
                let user = UserData(data: data)
                completion(.success(user))
            }
        }
    }
}
