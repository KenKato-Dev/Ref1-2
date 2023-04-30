//
//  ShoppingListModel.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/30.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import UIKit
struct ShoppingListItem: Decodable {
    var isBuying: Bool
    var itemName: String
    let itemID: String
}
final class ShoppingListModel {
    private let db = Firestore.firestore()
    private(set) var countOfDocuments = 0
    private(set) var queryDocumentSnaphots: [QueryDocumentSnapshot] = []
    private var items: [ShoppingListItem] = []
    private(set) var query = Firestore.firestore().collection("shoppingList").limit(to: 10)

    func postList(_ uid: String, _ item: ShoppingListItem) async throws {
        do {
            try await db.collection("Users").document(uid).collection("shoppingList").document("item:\(item.itemID)").setData([
                "isBuying": item.isBuying,
                "itemName": item.itemName,
                "itemID": item.itemID
            ])
        } catch {
            throw error
        }
    }
    func fetchList() async throws -> [ShoppingListItem] {
        do {
            let querySnapshot = try await self.query.getDocuments()
            let decoder = JSONDecoder()
            self.queryDocumentSnaphots.append(contentsOf: querySnapshot.documents)
            self.countOfDocuments = queryDocumentSnaphots.count
            let dictionaryDocuments = querySnapshot.documents.map { documentSnapshot in
                documentSnapshot.data()
            }
            let data = try JSONSerialization.data(withJSONObject: dictionaryDocuments, options: .prettyPrinted)
            let items = try decoder.decode([ShoppingListItem].self, from: data)
            self.items = items
            return self.items
        } catch {
            throw error
        }
    }
}
