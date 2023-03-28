//
//  MainViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/03/04.
//

import UIKit

class MainTabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
