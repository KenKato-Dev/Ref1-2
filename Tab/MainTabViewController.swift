//
//  MainViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/03/04.
//

import UIKit
protocol TabViewDelegate: AnyObject {
    func didTapAdd()
    func didTapDelete()
}
class MainTabViewController: UITabBarController {
    private var addButton = AddButton(type: .custom)
    private var deleteButton = DeleteButton(type: .custom)
    var bool = true
    weak var tabBarDelegate: TabViewDelegate? // delegateMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
extension MainTabViewController {
    func initialSetNavigationBar() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: provideAddButton())
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: provideDeleteButton())
    }
    func provideAddButton() -> UIButton {

        self.addButton.addAction(.init(handler: { _ in
            print("tappedAddButton & \(self.children[0]) &\(self.children[1])")
            self.tabBarDelegate?.didTapAdd()
        }), for: .touchUpInside)
        return self.addButton
    }
    func provideDeleteButton() -> UIButton {
        self.deleteButton.addAction(.init(handler: { _ in
            print("tappedDeleteButton")
            self.tabBarDelegate?.didTapDelete()
        }), for: .touchUpInside)
        return self.deleteButton
    }
}
