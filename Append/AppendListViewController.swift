//
//  AppendListViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/03/22.
//

import Foundation
import UIKit

final class AppendListViewController: UIViewController {
    @IBOutlet weak var appendTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var appendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
extension AppendListViewController: UITableViewDelegate {
}
extension AppendListViewController {
    func apply() {
    }
    func provideCell() {

    }
}
