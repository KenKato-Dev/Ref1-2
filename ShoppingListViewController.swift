//
//  ShoppingListViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/30.
//

import UIKit

class ShoppingListViewController: UIViewController {
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cautionTextLabel: UILabel!
    @IBOutlet weak var addToFoodListButton: UIButton!
    private let presenter = ShoppingListPresenter(shoppingListModel: ShoppingListModel())

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ShoppingListItem>
    private typealias DataSource = UITableViewDiffableDataSource<Int, ShoppingListItem>
    private var dataSource: DataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.delegate = self
        self.presenter.setOutput(shoppingListPresenterOutput: self)
        self.addButton.addAction(.init(handler: { _ in
            Task {
                try await self.presenter.didTapAddButton()
            }
        }), for: .touchUpInside)
        // ここでFetch
        Task {
            try await self.presenter.fetchItems()
            self.dataSource = UITableViewDiffableDataSource(
                tableView: self.table,
                cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
                    self?.returnCell(tableView, at: indexPath, item: itemIdentifier)
                }
            )
            self.apply()
            print(presenter.items)
//            self.table.reloadData()
        }
        self.table.register(ShoppingCell.nib(), forCellReuseIdentifier: "ShoppingCell")
    } // VDL
    override func viewWillAppear(_ animated: Bool) {
        print(presenter.items)
    }
}
extension ShoppingListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tapによる処理
        self.presenter.didSelectRow()
    }
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        //左へのスワイプによる操作
//    }
}
// extension ShoppingListViewController:
extension ShoppingListViewController: ShoppingListPresenterOutput {
    func generatingItem() -> ShoppingListItem {
        guard let itemNameText = self.itemNameTextField.text else {
            return ShoppingListItem(isBuying: false, itemName: "", itemID: UUID().uuidString)
        }
        let item = ShoppingListItem(isBuying: false, itemName: itemNameText, itemID: UUID().uuidString)
        return item
    }
    func reloadData() {
        self.table.reloadData()
    }
    func apply() {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(self.presenter.items, toSection: 0)
        dataSource?.defaultRowAnimation = .fade
        if let dataSource {
            dataSource.apply(snapShot, animatingDifferences: true)
        } else {
            dataSource?.applySnapshotUsingReloadData(snapShot)
        }
    }
    func returnCell(_ tableView: UITableView, at indexPath: IndexPath, item: ShoppingListItem) -> UITableViewCell {
        let identifier = "ShoppingCell"
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as? ShoppingCell
        else { return UITableViewCell()
        }
        cell.naming(item.itemName)
        cell.checkCircle(item.isBuying)
        return cell
    }
}
