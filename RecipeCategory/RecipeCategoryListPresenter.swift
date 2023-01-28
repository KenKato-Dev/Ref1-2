//
//  RecipeCategoryPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/19.
//

import Foundation
import UIKit
protocol RecipeCategoryListPresenterOutput: AnyObject {
    func reloadData()
    func dismiss()
    func setTitle()
    func showIndicator()
    func hideIndicator(_ isHidden: Bool)
    func showNoResult()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
    func showJumpMessageIfNeeded(indexPath: IndexPath)
}

final class RecipeCategoryListPresenter {
    private(set) var array: [Small] = []
    private weak var recipeCategoryListPresenterOutput: RecipeCategoryListPresenterOutput?
    private let recipeModel: RecipeModel
    init(recipeModel: RecipeModel) {
        self.recipeModel = recipeModel
    }

    func setOutput(recipeCategoryListPresenterOutput: RecipeCategoryListPresenterOutput?) {
        self.recipeCategoryListPresenterOutput = recipeCategoryListPresenterOutput
    }

    // indicatorの表示と楽天APIへのリクエストを実施
    func reloadArray(searchKeyword: String?) {
        recipeCategoryListPresenterOutput?.showIndicator()
        if let searchKeyword = searchKeyword {
            recipeModel.fetch(searchKeyword) { result in
                switch result {
                case let .success(categories):
                    self.array = categories
                    self.recipeCategoryListPresenterOutput?.reloadData()
                    self.recipeCategoryListPresenterOutput?.hideIndicator(true)
                    if self.array.isEmpty {
                        self.recipeCategoryListPresenterOutput?.showNoResult()
                    }
                case let .failure(error):
                    self.recipeCategoryListPresenterOutput?.presentErrorIfNeeded(error)
                    self.recipeCategoryListPresenterOutput?.dismiss()
                }
            }
            recipeCategoryListPresenterOutput?.setTitle()
        }
    }

    func categoryListInRow(forRow row: Int) -> Small? {
        guard row < array.count else { return nil }
        return array[row]
    }

    func numberOfRows() -> Int {
        array.count
    }

    func cellForRowAt(indexPath: IndexPath) -> String {
        array[indexPath.row].categoryName
    }

    func didSelectRow(indexPath: IndexPath) {
        recipeCategoryListPresenterOutput?
            .showJumpMessageIfNeeded(indexPath: indexPath)
    }

    func openUrl(indexPath: IndexPath) {
        if UIApplication.shared.canOpenURL(URL(string: array[indexPath.row].categoryUrl)!) {
            UIApplication.shared.open(URL(string: array[indexPath.row].categoryUrl)!)
        } else {
            print("URLとして開けません:\(URL(string: array[indexPath.row].categoryUrl)!)")
        }
    }
}
