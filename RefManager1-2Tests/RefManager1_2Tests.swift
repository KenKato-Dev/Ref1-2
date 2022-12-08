//
//  RefManager1_2Tests.swift
//  RefManager1-2Tests
//
//  Created by 加藤研太郎 on 2022/11/27.
//

import XCTest
@testable import RefManager1_2

class RefManager1_2Tests: XCTestCase {
    var viewController: FoodListViewController!
    var food = Food(location: .refrigerator, kind: .other, name: "unittest", quantity: "10", unit: .piece, IDkey: "IDKeyForSample", date: .now)
    let model = FoodData()
    func test_post機能() {
        self.model.post(self.food) { result in
            switch result {
            case let .success(success):
                print(success)
            case let .failure(err):
                print(err)
            }
        }
    }
    func test_fetch機能() {
        self.model.fetch { result in
            switch result {
            case let .success(foods):
                print(foods)
            case let .failure(err):
                print(err)
            }
        }
    }
    func test_delete機能() {
        let ids = [UUID().uuidString]
        self.model.delete(ids) { result in
            switch result {
            case let .success(success):
                print(success)
            case let .failure(err):
                print(err)
            }
        }
    }
    func test(){
        self.model.
    }
}
// ModelはUIテスト、ビジネスロジックのテスト、データベースにつなげずに参照するのみ、
// データベースの参照＋ビジネスロジックのメソッドの分けて
// firebaseのMockで調べた方が良い
// class FoodDataMock: FoodDataProtocol {
//    func post(_ food: Food) {
//        <#code#>
//    }
//
//    func fetch(_ completion: @escaping (Result<[Food], Error>) -> Void) {
//        <#code#>
//    }
//
//    func isConfiguringQuery(_ filterRef: Bool, _ filterFreezer: Bool, _ filter: FoodData.Filter, _ kinds: [Food.FoodKind]) {
//        <#code#>
//    }
//
//    func paginate() {
//        <#code#>
//    }
//
//    func delete(_ idKeys: [String], _ completion: @escaping (Result<Void, Error>) -> Void) {
//        <#code#>
//    }
//
// }
