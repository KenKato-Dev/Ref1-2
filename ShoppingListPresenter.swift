//
//  ShoppingListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/30.
//

import Foundation
import Firebase
protocol ShoppingListPresenterOutput: AnyObject {
    func generatingItem() -> ShoppingListItem
    func reloadData()
    func apply()
    func returnCell(_ tableView: UITableView, at indexPath: IndexPath, item: ShoppingListItem) -> UITableViewCell
}
final class ShoppingListPresenter {
    private weak var shoppingListPresenterOutput: ShoppingListPresenterOutput?
    private let shoppingListModel: ShoppingListModel
    private (set) var items: [ShoppingListItem]=[]
    init(shoppingListModel: ShoppingListModel) {
        self.shoppingListModel = shoppingListModel
    }

    func setOutput(shoppingListPresenterOutput: ShoppingListPresenterOutput) {
        self.shoppingListPresenterOutput = shoppingListPresenterOutput
    }
    func fetchItems() async throws {
            let fetchedItems = try await self.shoppingListModel.fetchList()
            items.append(contentsOf: fetchedItems)
    }
    func didTapAddButton() async throws {

        guard let uid = Auth.auth().currentUser?.uid, let item = shoppingListPresenterOutput?.generatingItem() else { return }
        try await self.shoppingListModel.postList(uid, item)
        try await self.fetchItems()
    }
    func didSelectRow(at indexPath:IndexPath) {
        //ItemのisBuyingをとぐる
//        self.items[indexPath.row].isBuying.toggle()
        //情報を上書き
    }
    func didTapAddtoFoodListButton() {

    }
    func didTapShareButton() {

    }
}
