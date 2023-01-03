//
//  RefManager1_2Tests.swift
//  RefManager1-2Tests
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import XCTest
import Firebase
import FirebaseFirestoreSwift
@testable import RefManager1_2

class RefManagerModelTests: XCTestCase { // RefManager1_2
    var mock = FoodDataMock()
    var testFood = RefManager1_2.Food.init(location: Food.Location.allCases.randomElement()!,
                                           kind: RefManager1_2.Food.FoodKind.allCases.randomElement()!,
                                           name: "testFood", quantity: String(Int.random(in: 1...100)),
                                           unit: .gram, IDkey: UUID().uuidString, date: .now)
    let exp = XCTestExpectation(description: "test実行")
    func test_post機能() {
        let successMessage = "書き込みに成功"
        mock.test_post動作(testFood) { result in
            switch result {
            case let .success(success):
                XCTAssertEqual(success, successMessage)
                self.exp.fulfill()
            case let .failure(err):
                XCTAssertThrowsError(err)
                self.exp.fulfill()
            }
        }
        self.wait(for: [self.exp], timeout: 5.0)
    }
    func test_fetch機能() {
        self.mock.test_fetch動作 { result in
            switch result {
            case .success:
                self.exp.fulfill()
            case let .failure(err):
                XCTAssertThrowsError(err)
                self.exp.fulfill()
            }
        }
        self.wait(for: [self.exp], timeout: 5.0)
    }
    func test_delete機能() {
        let ids = ["12A1B1C4-572C-47AE-9250-2F113C28DC44", "4DFB190E-C227-4904-A495-691A7AC03672"]
        let deleteMessage = "削除成功"
        self.mock.test_delete動作(ids) { result in
            switch result {
            case let .success(success):
                XCTAssertEqual(success, deleteMessage)
                self.exp.fulfill()
            case let .failure(err):
                XCTAssertThrowsError(err)
                self.exp.fulfill()
            }
        }
        self.wait(for: [self.exp], timeout: 5.0)
    }
    func test_isConfiguringQuery動作() {
    }
}
    // ModelはUIテスト、ビジネスロジックのテスト、データベースにつなげずに参照するのみ、
    // データベースの参照＋ビジネスロジックのメソッドの分けて
    class FoodDataMock {
        var collectionQuery =  Firestore.firestore().collection("unitTest")
        let db = Firestore.firestore()
        var countOfDocuments = 0
        var queryDocumentSnaphots: [QueryDocumentSnapshot]=[]
        func test_post動作(_ food: Food, _ completion: @escaping (Result<String, Error>) -> Void) {
            DispatchQueue.global().async {
                self.db.collection("unitTest").document("\("IDkey"): \(food.IDkey)").setData([
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
                        completion(.success("書き込みに成功"))

                    }
                }
            }
        }

        func test_fetch動作(_ completion: @escaping (Result<[Food], Error>) -> Void) {
            self.countOfDocuments = 0
            DispatchQueue.global().async {
                self.collectionQuery.getDocuments { querySnapShot, error in
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
                        let dictinaryDocuments = querySnapShot.documents.map { snapshot in
                            snapshot.data()
                        }
                        do {
                            let data = try JSONSerialization.data(
                                withJSONObject: dictinaryDocuments,
                                options: .prettyPrinted)
                            var decodedFoods = try decoder.decode([Food].self, from: data)
                            completion(.success(decodedFoods))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
        func test_delete動作(_ idKeys: [String], _ completion: @escaping (Result<String, Error>) -> Void) {
            let query = db.collection("unitTest").whereField("IDkey", in: idKeys)
            DispatchQueue.global().async {
                query.getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    let batch = self.db.batch()
                    guard let snapshot = snapshot else {return}
                    snapshot.documents.forEach {batch.deleteDocument($0.reference)}
                    print(batch.accessibilityElementCount()) // 0でも処理上問題なければ通す
                    batch.commit { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success("削除成功"))
                        }
                    }
                }
            }
        }
            func test_isConfiguringQuery動作(_ filterRef: Bool, _ filterFreezer: Bool, _ filter: FoodData.Filter, _ kinds: [Food.FoodKind]) -> Query {
                let kindArray = filter.kindArray.map {$0.rawValue}
                let location = filter.location.rawValue
                let kinds = kinds.map {$0.rawValue}

                if (filterRef || filterFreezer) && !kinds.isEmpty {
                    // 1.冷蔵/冷凍がtrueでかつfoodも選択
                    return Firestore.firestore().collection("unitTest").whereField("location", isEqualTo: location)
                        .whereField("kind", in: kindArray).order(by: "kindNumber").order(by: "date").limit(to: 10)
                } else if (filterRef || filterFreezer) && kinds.isEmpty {
                    // 2.冷蔵/冷凍のみtrue
                    return Firestore.firestore().collection("unitTest").whereField("location", isEqualTo: location)
                        .order(by: "kindNumber").order(by: "date").limit(to: 10)
                } else if (!filterRef && !filterFreezer) && !kinds.isEmpty {
                    // 3.foodのみ選択
                    return Firestore.firestore().collection("unitTest").whereField("kind", in: kindArray)
                        .order(by: "kindNumber").order(by: "date").limit(to: 10)
                } else {
                    // 4.何も選択されていない状態
                    return  Firestore.firestore().collection("unitTest").order(by: "kindNumber")
                        .order(by: "date").limit(to: 10)
                }
            }
        //
        //    func paginate() {
        //        <#code#>
        //    }
        //
    }
