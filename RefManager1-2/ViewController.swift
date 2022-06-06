//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var foodLocation: [Food] = []
    private var foodfilteredbyKind: [Food] = []
    private var foodLocationAndKind: [Food] = []
    private var foodFiter: FoodData.Fiter = .init(location: .refrigerator, kind: Food.FoodKind.allCases)
    private let foods = FoodData.shared
    private let foodUseCase = FoodUseCase.shared
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
    // 食材種類を判断するDictionary
    var foodKindDictionary: [Food.FoodKind: Bool] = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
            .seasoning: false, .sweet: false, .other: false
        ]
    // 食材種類を判断するDictionary
//        var foodKindDictionary: [Food.FoodKind: Bool] = [
//            .meat: false, .fish: false, .vegetableAndFruit: false, .milkAndEgg: false, .dish: false, .drink: false, .seasoning: false, .sweet: false, .other: false
//        ]
    // 表示切り替え
    private var filterForMeet = false
//    private var filterForFish = false
//    private var filterForVegAndFluits = false
//    private var filterForMilkAndEgg = false
//    private var filterForDish = false
//    private var filterForDrink = false
//    private var filterForSeasoning = false
//    private var filterForSweet = false
//    private var filterForOther = false
    var checkedIDDictionary: [String: Bool] = [:]

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
//            FoodUseCase().filterFoodLocation(
//                boolForLocation: self.foodUseCase.filterForRefrigerator,
//                boolForAnotherLocation: self.foodUseCase.filterForFreezer,
//                location: .refrigerator,
//                foodLocation: self.foodLocation,
//                foodFilter: self.foodFiter)

            self.foodUseCase.filterForFreezer = false
            self.foodUseCase.filterForRefrigerator.toggle()
            self.foodLocation = []
            self.foodFiter.location = .refrigerator
            self.addFilteredFood()
            print(self.foodLocation)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        // 冷凍庫ボタンのアクション
        self.filteredFreezerButton.addAction(.init(handler: { _ in
//            FoodUseCase().filterFoodLocation(
//                boolForLocation: self.filterForFreezer,
//                boolForAnotherLocation: self.filterForRefrigerator,
//                location: .freezer,
//                foodLocation: self.foodLocation,
//                foodFilter: self.foodFiter)

            self.foodUseCase.filterForRefrigerator = false
            self.foodUseCase.filterForFreezer.toggle()
            self.foodLocation = []
            self.foodFiter.location = .freezer
            self.addFilteredFood()
//            print(self.foodLocation)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        // うまく作動せず
        self.filterForMeetButton.addAction(.init(handler: { _ in

//            foodSelect2(selectedFoods: self.foodfilteredbyKind, foodKind: .meat)
            self.addFilteredByKinds(foodKind: .meat)
            print(self.foodfilteredbyKind)
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
        if (self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator) && foodLocation.count != 0 {
           return  foodLocation.count
        } else {
            return foods.getfoodArray().count
        }
//        if foodFiter.kind ==  {
//        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        cell?.dateTextLabel.text = dateFormatter.string(from: Date())
        if (self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator) && foodLocation.count != 0 {
            cell?.foodImage.image = UIImage(named: "\(foodLocation[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = foodLocation[indexPath.row].location.rawValue
            cell?.foodNameTextLabel.text = foodLocation[indexPath.row].name
            cell?.quantityTextLabel.text = String(foodLocation[indexPath.row].quantity)
            cell?.unitTextLabel.text = foodLocation[indexPath.row].unit.rawValue
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
        self.foodLocation.append(contentsOf: self.foods.filterationOfFood(with: self.foodFiter))
    }
    // 食材ボタンを押すとリストにそれを表示する
    func foodSelect(boolOfKind: Bool, foodKind: Food.FoodKind) {
        if boolOfKind && (self.foodUseCase.filterForRefrigerator || self.foodUseCase.filterForFreezer) {
            self.foodLocationAndKind = []
            self.foodLocationAndKind = self.foodLocation.filter {$0.kind == foodKind}
        } else if !boolOfKind && (self.foodUseCase.filterForRefrigerator || self.foodUseCase.filterForFreezer) {
            self.foodLocation
        }
    }
    // ボタンが押されたらfoodKindDic内のkey値を切り替える
    func addFilteredByKinds(foodKind: Food.FoodKind) {
        foodKindDictionary[foodKind]!.toggle()
        let selectedKinds = foodKindDictionary.filter {$0.value == true}
        let kinds = selectedKinds.map {$0.key}
        self.foodFiter.kind = kinds
        self.foodfilteredbyKind.append(contentsOf: self.foods.filterationOfFood(with: self.foodFiter))
    }
}
