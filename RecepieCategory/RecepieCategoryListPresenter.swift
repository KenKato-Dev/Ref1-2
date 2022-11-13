//
//  RecepieCategoryPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/19.
//

import Foundation
import UIKit
protocol RecepieCategoryListPresenterOutput: AnyObject {
    func reloadData()
    func dismiss()
    func setTitle()
}
final class RecepieCategoryListPresenter {
    private (set) var array: [Small]=[]
    weak private var recepieCategoryListPresenterOutput: RecepieCategoryListPresenterOutput?
    private let recepieModel: RecepieModel
    init(recepieModel: RecepieModel) {
        self.recepieModel = recepieModel
    }
    func setOutput(recepieCategoryListPresenterOutput: RecepieCategoryListPresenterOutput?) {
        self.recepieCategoryListPresenterOutput = recepieCategoryListPresenterOutput
    }

    func reloadArray(searchKeyword: String?) {
        if let searchKeyword = searchKeyword {
        recepieModel.fetchCategory(keyword: searchKeyword) { result in
            switch result {
            case .success(let categories):
                self.array = categories
                self.recepieCategoryListPresenterOutput?.reloadData()
            case.failure(let error):
                print(error)
                self.recepieCategoryListPresenterOutput?.dismiss()
            }
        }
        self.recepieCategoryListPresenterOutput?.setTitle()
    }
    }
    func categoryListInRow(forRow row: Int) -> Small? {
        guard row < array.count else {return nil}
        return array[row]
    }
    func numberOfRows() -> Int {
            return self.array.count
    }
    func cellForRowAt(indexPath: IndexPath) -> String {
        return self.array[indexPath.row].categoryName
    }
    func didSelectRow(indexPath: IndexPath) {

        if UIApplication.shared.canOpenURL(URL(string: (array[indexPath.row].categoryUrl))!) {
            UIApplication.shared.open(URL(string: (array[indexPath.row].categoryUrl))!)
        } else {
            print("URLとして開けません:\(URL(string: (array[indexPath.row].categoryUrl))!)")
        }
    }
}
