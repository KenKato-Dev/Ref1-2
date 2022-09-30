//
//  FoodData.swift
//  LikeTabTraining
//
//  Created by 加藤研太郎 on 2022/04/05.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct StringTo<T: LosslessStringConvertible> {
    let value: T
}
extension StringTo: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = T(string) else {
            let debugDescription = "'\(string)' は\(T.self)にStringToのコンバート処理ができませんでした."
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: debugDescription
            )
            throw DecodingError.dataCorrupted(context)
        }
        self.value = value
    }
}
extension DateFormatter {
    /// ミリ秒付きのiso8601フォーマット e.g. 2019-08-22T09:30:15.000+0900
    /// Firestore内での記述：2022-07-06 09:21:22 +0000
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        // 上記記述内容からフォーマットは下記の通りと推察
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
extension Decoder {

}

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
        //        case refrigerator = "冷蔵"
        //        case freezer = "冷凍"
        case refrigerator
        case freezer
    }
    // CaseIterableでallCasesが使用可能になる
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
    }
}
struct FoodForTest: Decodable {
    var location: Location
    var kind: FoodKind
    var name: String
    var quantity: StringTo<Double>
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date
    enum Location: String, CaseIterable, Codable {
        //        case refrigerator = "冷蔵"
        //        case freezer = "冷凍"
        case refrigerator
        case freezer
    }
    // CaseIterableでallCasesが使用可能になる
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
    }
}
struct Recepie: Codable {
    let foodImageUrl: String
    let mediumImageUrl: String
    let nickname: String
    let pickup: Int
    let rank: String
    let recipeCost: String
    let recipeDescription: String
    let recipeId: Int
    let recipeIndication: String
    let recipeMaterial: [String]
    let recipePublishday: String
    let recipeTitle: String
    let recipeUrl: String
    let shop: Int
    let smallImageUrl: String
}
class FoodData {
    struct Fiter: Codable {
        var location: Food.Location
        var kind: [Food.FoodKind]
    }
    static var shared: FoodData = FoodData()
//    static let queue = DispatchQueue(label: "queue")
//    private var foodsArray: [Food] = []
    private let db = Firestore.firestore()

//    func add(_ food: Food) {
//        foodsArray.append(food)
//    }
    // firestoreへの保存
    func addtoDataBase(_ food: Food) {
        let db = Firestore.firestore()
        // ドキュメントごとに保管
        db.collection("foods").document("IDkey: \(food.IDkey)").setData([
            "location": "\(food.location)",
            "kind": "\(food.kind)",
            "name": "\(food.name)",
            "quantity": "\(food.quantity)",
            "unit": "\(food.unit)",
            "IDkey": "\(food.IDkey)",
            "date": "\(food.date)"
        ], merge: false) { err in
            if let err = err {
                print("FireStoreへの書き込みに失敗しました: \(err)")
            } else {
                print("FireStoreへの書き込みに成功しました")
            }
        }
    }

    // FireStoreから[food]として読み込み、Resultを使うことで綺麗に記述、Escapingがなければエラー
    func fetchFoods(_ completion:@escaping (Result<[Food], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.db.collection("foods").getDocuments { querySnapShot, error in
                if let err = error {
                    completion(.failure(err))
                    print("FireStoreへの読み込みに失敗しました: \(err)")
                } else {
                    print("FireStoreへの読み込みに成功しました")
                    // ここから非同期処理？

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
                    // 下記でDictionaryに変換
                    var dictinaryDocuments = querySnapShot?.documents.map({ snapshot in
                        snapshot.data()
                    })
                    do {
                        // 下記でDictionaryをdata→JsonString→[Food]に変換
                        let data = try JSONSerialization.data(withJSONObject: dictinaryDocuments, options: .prettyPrinted)
                        //                    let jsonSting = try String(data: data, encoding: .utf8)!
                        //                    let datafromJson = jsonSting.data(using: .utf8)
                        let decodedFoods = try decoder.decode([Food].self, from: data)
                        completion(.success(decodedFoods))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func delete(_ idKeys: [String], _ completion:@escaping (Result<Void, Error>) -> Void) {
        guard !idKeys.isEmpty else {
            return
        }
                let query = self.db.collection("foods").whereField("IDkey", in: idKeys)
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

    func getDocument(_ completion: @escaping([Food]) -> Void) -> [Food] {
        var array: [Food] = []
        let loadedFromFireStore = db.collection("foods")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        loadedFromFireStore.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("ERROR getDocument:\(error)")
                return
            }
            let dictionary = querySnapshot?.documents.map({ snapshot in
                snapshot.data()
            })
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                let decodedFoods = try decoder.decode([Food].self, from: data)
                array = decodedFoods
            } catch {
                print(error)
            }
        }
        return array
    }

    func returnFood(queryDocumentSnapshot: [QueryDocumentSnapshot])async throws -> [Food]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        // 下記でDictionaryに変換
        return try await withCheckedThrowingContinuation { continuation in
            db.collection("foods").getDocuments { querySnapShot, error in
                if let err = error {
                    print("FireStoreへの読み込みに失敗しました: \(err)")
                } else {
                    print("FireStoreへの読み込みに成功しました")
                    // ここから非同期処理？
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
                    // 下記でDictionaryに変換
                    var dictinaryDocuments = querySnapShot?.documents.map({ snapshot in
                        snapshot.data()
                    })
                    do {
                        // 下記でDictionaryをdata→JsonString→[Food]に変換
                        let data = try JSONSerialization.data(withJSONObject: dictinaryDocuments, options: .prettyPrinted)
                        //                    let jsonSting = try String(data: data, encoding: .utf8)!
                        //                    let datafromJson = jsonSting.data(using: .utf8)
                        let decodedFoods = try decoder.decode([Food].self, from: data)
                        continuation.resume(returning: decodedFoods)
                    } catch {
                        print(error)
                    }
                }
            }
        }
}
    // APIからランキングを取得
    //この部分をMyplaygroundのランキング取得に変換、ここからURLとタイトルを取り出す
    func fetchRankingFromAPI(_ completion:@escaping(Result<[Recepie], Error>) -> Void) {
        guard let url = URL(string: "https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&applicationId=1014272479943576132") else { return }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("URL取得に失敗:\(error)")
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    do {
                        let recepieData = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                        let dictionary = recepieData?["result"] as?([[String: Any]])
                        let data = try JSONSerialization.data(withJSONObject: dictionary!, options: .prettyPrinted)
                        let decodedResult = try decoder.decode([Recepie].self, from: data)
                        completion(.success(decodedResult))
                    } catch {
                        print("デコードに失敗:\(error)")
                    }
                }
            }
            task.resume()
    }
    // APIからカテゴリを取得
    func fetchCategoryFromAPI(_ completion:@escaping(Result<[Recepie], Error>) -> Void) {

    }
}
