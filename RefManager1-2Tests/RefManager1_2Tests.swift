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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let storyboard = UIStoryboard(name: "viewController", bundle: nil)
        self.viewController = storyboard.instantiateInitialViewController() as? FoodListViewController
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        viewController.loadViewIfNeeded()

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
class FoodDataMock: FoodDataProtocol {
    func post(_ food: Food) {
        <#code#>
    }

    func fetch(_ completion: @escaping (Result<[Food], Error>) -> Void) {
        <#code#>
    }

    func isConfiguringQuery(_ filterRef: Bool, _ filterFreezer: Bool, _ filter: FoodData.Filter, _ kinds: [Food.FoodKind]) {
        <#code#>
    }

    func paginate() {
        <#code#>
    }

    func delete(_ idKeys: [String], _ completion: @escaping (Result<Void, Error>) -> Void) {
        <#code#>
    }

}
