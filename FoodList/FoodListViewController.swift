//
//  FoodListViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import UIKit

final class FoodListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
// UItableView関連
// extension FoodListViewController:UITableViewDelegate, UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//    
// }
extension FoodListViewController: FoodListPresenterOutput {
    func didLoadView() {
        // self.tableView.reloadData()
    }
        //        self.foodUseCase.filterForRefrigerator.toggle()
        //        self.foodUseCase.filterForFreezer = false
        //        self.switchLocation(targetLocation: .refrigerator)
    }
