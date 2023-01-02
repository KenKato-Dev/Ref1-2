//
//  FoodData.swift
//  LikeTabTraining
//
//  Created by 加藤研太郎 on 2022/04/05.
//
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import UIKit

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

// Firebaseからデコード時に取り出せる形に調整
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
// カスタム構造、Firebase上の情報をこの構造にデコード
struct Food: Equatable, Codable {
    var location: Location
    var kind: FoodKind
    var name: String
    var quantity: String
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date

    enum Location: String, CaseIterable, Codable {
        case refrigerator
        case freezer
    }
// 食材の種類に対応するEnum、Query作成用に変数kindNumberを持つ
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

        var kindNumber: String {
            switch self {
            case .meat:
                return "1"
            case .fish:
                return "2"
            case .vegetableAndFruit:
                return "3"
            case .milkAndEgg:
                return "4"
            case .dish:
                return "5"
            case .drink:
                return "6"
            case .seasoning:
                return "7"
            case .sweet:
                return "8"
            case .other:
                return "9"
            }
        }
    }
}
// FoodDataクラスのプロトコル
protocol FoodDataProtocol {
    func post(_ uid: String, _ food: Food, _ completion: @escaping (Result<Void, Error>) -> Void)
    func fetch(_ completion: @escaping (Result<[Food], Error>) -> Void)
    func isConfiguringQuery(
        _ uid: String, _ filterRef: Bool, _ filterFreezer: Bool,
        _ filter: FoodData.Filter, _ kinds: [Food.FoodKind]
    )
    func paginate()
    func delete(_ uid: String, _ idKeys: [String], _ completion: @escaping (Result<Void, Error>) -> Void)
}
// FoodListとFoodAdditionのModelになるクラス、Firebaseへの書込み、リクエスト処理
final class FoodData: FoodDataProtocol {
// FIrebaseから取り出すQuery構成の際およびボタン操作時もフィルターとなる構造体
    struct Filter: Codable {
        var location: Food.Location
        var kindArray: [Food.FoodKind]
    }
    private let db = Firestore.firestore()
    private let collectionPath = "foods"
    private let fieldElementIDKey = "IDkey"
    private let fieldElementLocation = "location"
    private let fieldElementKind = "kind"
//    private (set) var query:Query?
    private (set) var query = Firestore.firestore().collection("foods").order(by: "kind").limit(to: 10)
//    private (set) var query:((String) -> Query) = { (_ uid:String) -> Query in
//       return Firestore.firestore().collection(uid).order(by: "kind").limit(to: 10)
//    }
    private (set) var queryDocumentSnaphots: [QueryDocumentSnapshot] = []
    private (set) var countOfDocuments = 0

    // Firebaseへの書込み処理
    func post(_ uid: String, _ food: Food, _ completion: @escaping (Result<Void, Error>) -> Void) {
        // ドキュメントごとに保管、ドキュメントを他のものにするとDictionary方式に上書きされる
        self.db.collection("Users").document(uid).collection("foods")
            .document("\(self.fieldElementIDKey): \(food.IDkey)").setData([
                "location": "\(food.location)",
                "kind": "\(food.kind)",
                "kindNumber": "\(food.kind.kindNumber)",
                "name": "\(food.name)",
                "quantity": "\(food.quantity)",
                "unit": "\(food.unit)",
                "IDkey": "\(food.IDkey)",
                "date": "\(food.date)"
            ], merge: false) { error in
                if let error = error {
                    completion(.failure(error))
                    print("FireStoreへの書き込みに失敗しました: \(error)")
                } else {
                    completion(.success(()))
                    print("FireStoreへの書き込みに成功しました")
                }
            }
    }
    // FirebaseへUpdationView経由で書込みする際の処理
    func postFromUpdationView(_ uid: String, foodName: String?, foodQuantity: String?,
                              foodinArray: Food, _ completion: @escaping (Result<Void, Error>) -> Void) {
        self.db.collection("Users").document(uid).collection("foods")
            .document("\(self.fieldElementIDKey): \(foodinArray.IDkey)").setData([
            "name": "\(foodName!)",
            "quantity": "\(foodQuantity!)",
            "date": "\(Date())",
            "IDkey": "\(foodinArray.IDkey)",
            "kind": "\(foodinArray.kind)",
            "kindNumber": "\(foodinArray.kind.kindNumber)",
            "unit": "\(foodinArray.unit)"
        ], merge: true) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    // UpdationView経由の保管場所変更処理
    func setLocation(_ uid: String, _ IDKey: String, _ location: String) {
        self.db.collection("Users").document(uid).collection("foods")
            .document("\(self.fieldElementIDKey): \(IDKey)").setData([
            self.fieldElementLocation: "\(location)"
        ])
    }
    // Firebaseから情報を読み込む処理
    func fetch(_ completion: @escaping (Result<[Food], Error>) -> Void) {

            self.countOfDocuments = 0
            self.query.getDocuments { querySnapShot, error in
                if let err = error {
                    completion(.failure(err))
                    print("FireStoreへの読み込みに失敗しました: \(err)")
                } else {
                    print("FireStoreへの読み込みに成功しました")
                    guard let querySnapShot = querySnapShot else { return }
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601Full)
                    self.queryDocumentSnaphots.append(contentsOf: querySnapShot.documents)
                    self.countOfDocuments = querySnapShot.documents.count
                    let dictinaryDocuments = querySnapShot.documents.map { documentSnapshot in
                        documentSnapshot.data()
                    }
                    do {
                        let data = try JSONSerialization.data(
                            withJSONObject: dictinaryDocuments,
                            options: .prettyPrinted
                        )
                        let decodedFoods = try decoder.decode([Food].self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decodedFoods))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
//        }
    }
    // 上記Fetch前にて使用するQuery作成処理、ボタンによるBool値と選択された食材の配列から処理
    func isConfiguringQuery(_ uid: String,
                            _ filterRef: Bool,
                            _ filterFreezer: Bool,
                            _ filter: Filter,
                            _ kinds: [Food.FoodKind]) {
        let kindArray = filter.kindArray.map {$0.rawValue}
        let location = filter.location.rawValue
        let kinds = kinds.map {$0.rawValue}

        if (filterRef || filterFreezer) && !kinds.isEmpty {
            // 1.冷蔵/冷凍がtrueでかつfoodも選択
            self.query = self.db.collection("Users").document(uid).collection("foods")
                .whereField(self.fieldElementLocation, isEqualTo: location)
                .whereField(self.fieldElementKind, in: kindArray)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else if (filterRef || filterFreezer) && kinds.isEmpty {
            // 2.冷蔵/冷凍のみtrue
            self.query = self.db.collection("Users").document(uid).collection("foods")
                .whereField(self.fieldElementLocation, isEqualTo: location)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else if (!filterRef && !filterFreezer) && !kinds.isEmpty {
            // 3.foodのみ選択
            self.query = self.db.collection("Users").document(uid).collection("foods")
                .whereField(self.fieldElementKind, in: kindArray)
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        } else {
            // 4.何も選択されていない状態
            self.query = Firestore.firestore().collection("Users").document(uid).collection("foods")
                .order(by: "kindNumber").order(by: "date").limit(to: 10)
        }
    }
    // ページネート用のquery調整処理、前回取り出したQDSの最後の1つあとからQueryを作成
    func paginate() {
        guard let nextDocument = queryDocumentSnaphots.last else { return}
        query = query.start(afterDocument: nextDocument).limit(to: 10)

    }
    // 削除処理
    func delete(_ uid: String, _ idKeys: [String], _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard !idKeys.isEmpty else {
            return
        }
        let query = self.db.collection("Users").document(uid).collection("foods")
            .whereField(self.fieldElementIDKey, in: idKeys)
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let batch = self.db.batch()
            guard let snapshot = snapshot else {return}
            snapshot.documents.forEach {batch.deleteDocument($0.reference)}
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
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
