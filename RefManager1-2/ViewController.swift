//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var filteredFoods: [Food] = []
    private var foodFiter: FoodData.Fiter = .init(location: .refrigerator, kind: Food.FoodKind.allCases)
    private let foods = FoodData.shared
    @IBOutlet weak var filterRefrigeratorButton: UIButton!
    @IBOutlet weak var filteredFreezerButton: UIButton!
    @IBOutlet weak var filterForMeetButton: UIButton!
    @IBOutlet weak var filterForFishButton: UIButton!
    @IBOutlet weak var filterForVegAndFruitsButton: UIButton!
    @IBOutlet weak var filterForMilkAndEggButton: UIButton!
    @IBOutlet weak var filterForDishButton: UIButton!
    @IBOutlet weak var filterForDrinkButton: UIButton!
    @IBOutlet weak var filterForSeasoningButton: UIButton!
    @IBOutlet weak var filterForSweetButton: UIButton!
    @IBOutlet weak var filterForOthersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTitle: UINavigationItem!
    @IBOutlet weak var deleteButton: DeleteButton!
    private var isChange = true
    // 表示切り替え
    private var filterForRefrigerator = false
    private var filterForFreezer = false
    private var filterForMeet = false
    private var filterForFish = false
    private var filterForVegAndFluits = false
    private var filterForMilkAndEgg = false
    private var filterForDish = false
    private var filterForDrink = false
    private var filterForSeasoning = false
    private var filterForSweet = false
    private var filterForOther = false
    var checkedIDDictionary: [String: Bool] = [:]
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        // 削除ボタン
        deleteButton.addAction(.init(handler: { _ in
            self.isChange.toggle()
            self.deleteButton.imageChange(bool: self.isChange)
            // 再度タップしてisChangeがfalseに切り替わった際の挙動、Bool値がTrueに設定
            if self.isChange {
                // filterで値のみを取り出し、defoはTrueを取り出すため
                let filteredIDDictionary = self.checkedIDDictionary.filter {$0.value}.map {$0.key}
                for key in filteredIDDictionary {
                    self.foods.removeFoods(key: key)
                    self.checkedIDDictionary = [:]
                }
            }
            // 下記の記述で上書きしないと項目を削除した後isTapはTrueのままとなる
            CheckBoxButton.isTap = false
            self.tableView.reloadData()
        }), for: .touchUpInside)
        // フィルターボタン
        // 冷蔵庫ボタンのアクション
        self.filterRefrigeratorButton.addAction(.init(handler: { _ in
            self.filterForFreezer = false
            self.filterForRefrigerator.toggle()
            self.filteredFoods = []
            self.foodFiter.location = .refrigerator
            self.addFilteredFood()
            print(self.filteredFoods)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        // 冷凍庫ボタンのアクション
        self.filteredFreezerButton.addAction(.init(handler: { _ in
            self.filterForRefrigerator = false
            self.filterForFreezer.toggle()
            self.filteredFoods = []
            self.foodFiter.location = .freezer
            self.addFilteredFood()
            print(self.filteredFoods)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        // うまく作動せず、冷蔵庫か冷凍庫のボタンでフィルターしたときのみ動作
        self.filterForMeetButton.addAction(.init(handler: { _ in
                self.filteredFoods = self.filteredFoods.filter {$0.kind == .meat}
            self.tableView.reloadData()
        }), for: .touchUpInside)
//        self.filterForFishButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForVegAndFruitsButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForMilkAndEggButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForDishButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForDrinkButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForSeasoningButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForSweetButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//        self.filterForOthersButton.addAction(.init(handler: { _ in
//            <#code#>
//        }), for: .touchUpInside)
//
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    // Intでリストの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filterForRefrigerator || filterForFreezer) && filteredFoods.count != 0 {
           return  filteredFoods.count
        } else {
            return foods.getfoodArray().count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        cell?.dateTextLabel.text = dateFormatter.string(from: Date())
        if (filterForRefrigerator || filterForFreezer) && filteredFoods.count != 0 {
            cell?.foodImage.image = UIImage(named: "\(filteredFoods[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = filteredFoods[indexPath.row].location.rawValue
            cell?.foodNameTextLabel.text = filteredFoods[indexPath.row].name
            cell?.quantityTextLabel.text = String(filteredFoods[indexPath.row].quantity)
            cell?.unitTextLabel.text = filteredFoods[indexPath.row].unit.rawValue
        } else {
            cell?.foodImage.image = UIImage(named: "\(foods.getfoodArray()[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = foods.getfoodArray()[indexPath.row].location.rawValue
            cell?.foodNameTextLabel.text = foods.getfoodArray()[indexPath.row].name
            cell?.quantityTextLabel.text = String(foods.getfoodArray()[indexPath.row].quantity)
            cell?.unitTextLabel.text = foods.getfoodArray()[indexPath.row].unit.rawValue
        }
        // 削除ボタンと連動
        cell?.showCheckBox = self.isChange
        // UUIDをDictionaryに追加
        cell?.didTapCheckBox = { isChecked in
            self.checkedIDDictionary[self.foods.getfoodArray()[indexPath.row].IDkey] = isChecked
        }
        cell?.checkBoxButton.updateAppearance(isChecked: checkedIDDictionary[self.foods.getfoodArray()[indexPath.row].IDkey] ?? false)
        return cell!
    }
    func addFilteredFood() {
        self.filteredFoods.append(contentsOf: self.foods.filterationOfFood(with: self.foodFiter))
    }
}
