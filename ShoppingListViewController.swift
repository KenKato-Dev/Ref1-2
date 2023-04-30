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
    private let shoppingListPresenter = ShoppingListPresenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shoppingListPresenter.setOutput(shoppingListPresenterOutput: self)
    }
}
extension ShoppingListViewController: ShoppingListPresenterOutput {

}
