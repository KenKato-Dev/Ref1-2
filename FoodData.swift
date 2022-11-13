//
//  FoodData.swift
//  LikeTabTraining
//
//  Created by 加藤研太郎 on 2022/04/05.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import UIKit

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// extension StringTo: Decodable {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let string = try container.decode(String.self)
//        guard let value = T(string) else {
//            let debugDescription = "'\(string)' は\(T.self)にStringToのコンバート処理ができませんでした."
//            let context = DecodingError.Context(
//                codingPath: decoder.codingPath,
//                debugDescription: debugDescription
//            )
//            throw DecodingError.dataCorrupted(context)
//        }
//        self.value = value
//    }
// }

// struct StringTo<T: LosslessStringConvertible> {
//    let value: T
// }

struct Food: Equatable, Codable {
    var location: Location
    var kind: FoodKind
    var name: String
    //    var quantity: Double
    var quantity: String
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date
    enum Location: String, CaseIterable, Codable {
        case refrigerator
        case freezer
    }

    enum FoodKind: String, CaseIterable, Codable {
        case meat
        case fish
        case vegetableAndFruit
        case milkAndEgg
        case dish
        case drink
        case seasoning
        case sweet
        case other
//        case meat = "1.meet"
//        case fish = "2.fish"
//        case vegetableAndFruit = "3.vegetableAndFruit"
//        case milkAndEgg = "4.milkAndEgg"
//        case dish = "5.dish"
//        case drink = "6.drink"
//        case seasoning = "7.seasoning"
//        case sweet = "8.sweet"
//        case other = "9.other"
    }
}

final class FoodData {
    struct Fiter: Codable {
        var location: Food.Location
        var kindArray: [Food.FoodKind]
    }

    private let db = Firestore.firestore()
    func post(_ food: Food) {
        // ドキュメントごとに保管、ドキュメントを他のものにするとDictionary方式に上書きされる
        db.collection("foods").document("IDkey: \(food.IDkey)").setData([
            "location": "\(food.location)",
            "kind": "\(food.kind)",
            "name": "\(food.name)",
            "quantity": "\(food.quantity)",
            "unit": "\(food.unit)",
            "IDkey": "\(food.IDkey)",
            "date": "\(food.date)",
        ], merge: false) { err in
            if let err = err {
                print("FireStoreへの書き込みに失敗しました: \(err)")
            } else {
                print("FireStoreへの書き込みに成功しました")
            }
        }
    }

    func fetch(_ completion: @escaping (Result<[Food], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { // +0.3を削除し動作確認
            self.db.collection("foods").getDocuments { querySnapShot, error in
                if let err = error {
                    completion(.failure(err))
                    print("FireStoreへの読み込みに失敗しました: \(err)")
                } else {
                    print("FireStoreへの読み込みに成功しました")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
                    var dictinaryDocuments = querySnapShot?.documents.map { snapshot in
                        snapshot.data()
                    }
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dictinaryDocuments, options: .prettyPrinted)
                        var decodedFoods = try decoder.decode([Food].self, from: data)
                        decodedFoods = decodedFoods.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                        completion(.success(decodedFoods))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func delete(_ idKeys: [String], _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard !idKeys.isEmpty else {
            return
        }
        let query = db.collection("foods").whereField("IDkey", in: idKeys)
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var count = 0
            for document in snapshot!.documents { // ここにsuccessを入れるとfor分毎に呼ばれる
                document.reference.delete { error in
                    count += 1
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if count == snapshot?.count {
                        completion(.success(()))
                    }
                }
            }
            completion(.success(()))
        }
    }
}
