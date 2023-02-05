//
//  AccountInformation.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import Firebase
import Foundation

class AccountInformation {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    func fetchUserInfo(_ completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let user = auth.currentUser else { return }
        if !user.isAnonymous {
            DispatchQueue.main.async {
                self.db.collection("Users").document(user.uid).getDocument { documentSnapshot, error in
                    if let error = error {
                        print("ユーザー情報取得に失敗:\(error)")
                        completion(.failure(error))
                        return
                    }
                    guard let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() else { return }
                    let user = UserData(data: data)
                    completion(.success(user))
                }
            }
        }
    }

    func signOut(_ completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            completion(.success(()))
            try auth.signOut()
        } catch {
            completion(.failure(error))
        }
    }

    func deleteAccount(_ completion: @escaping (Result<Void, Error>) -> Void) {
        auth.currentUser?.delete(completion: { error in
            guard let error = error else { return }
            completion(.failure(error))
        })
        completion(.success(()))
    }
}
