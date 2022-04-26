//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let foods = FoodData.shared
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTitle: UINavigationItem!
    @IBOutlet weak var deleteButton: DeleteButton!
    private var isChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        deleteButton.addAction(.init(handler: { _ in
            self.isChange.toggle()
            self.deleteButton.imageChange(bool: self.isChange)
            self.tableView.reloadData()
            print("tapされました")
        }), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    //Intでリストの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foods.getfoodArray().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        cell?.dateTextLabel.text = dateFormatter.string(from: Date())
        cell?.foodImage.image = UIImage(named: "\(foods.getfoodArray()[indexPath.row].kind.rawValue)")
        cell?.preserveMethodTextLable.text = foods.getfoodArray()[indexPath.row].refOrFreezer.rawValue
        cell?.foodNameTextLabel.text = foods.getfoodArray()[indexPath.row].name
        cell?.quantityTextLabel.text = String(foods.getfoodArray()[indexPath.row].quantity)
        cell?.unitTextLabel.text = foods.getfoodArray()[indexPath.row].unit.rawValue
        cell?.showCheckBox = self.isChange
        return cell!
        
    }
}

