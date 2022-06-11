//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
import SwiftUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let foods = FoodData.shared
    private let foodUseCase = FoodUseCase.shared
    private var foodLocation: [Food] = []
    private var foodfilteredbyKind: [Food] = []
    private var foodLocationAndKind: [Food] = []
    private var filteredFoodArray: [Food] = []
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
        self.filteredFoodArray = self.foods.getfoodArray()
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
            self.foodUseCase.filterForRefrigerator.toggle()
            self.foodUseCase.filterForFreezer = false
            self.switchLocation(targetLocation: .refrigerator)
        }), for: .touchUpInside)
        // 冷凍庫ボタンのアクション
        self.filteredFreezerButton.addAction(.init(handler: { _ in
            self.foodUseCase.filterForFreezer.toggle()
            self.foodUseCase.filterForRefrigerator = false
            self.switchLocation(targetLocation: .freezer)
        }), for: .touchUpInside)
        // うまく作動せず
        self.filterForMeetButton.addAction(.init(handler: { _ in
//            self.addFilteredByKinds(foodKind: .meat)
//            self.foodLocationAndKind = self.foods.getfoodArray()
//            self.filterationOfFoodArray(foodKind: .meat)
            self.foodUseCase.foodKindDictionary[.meat]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
//            self.foodUseCase.foodFilter.kind = kinds
//            self.filteredFoodArray = self.foods.getfoodArray()
//            self.filteredFoodArray = self.filteredFoodArray.filter {self.foodUseCase.foodFilter.kind.contains($0.kind) && $0.location == self.foodUseCase.foodFilter.location}
//            print(self.filteredFoodArray)
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
//        if (
//            self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator
//            || self.foodUseCase.foodFilter.kind != Food.FoodKind.allCases)
//            && (self.filteredFoodArray != foods.getfoodArray())
        if (!foodUseCase.filterForFreezer && !foodUseCase.filterForRefrigerator) && (self.foodUseCase.selectedKinds.isEmpty) {
//        if self.filteredFoodArray != foods.getfoodArray() {
            return foods.getfoodArray().count
//        } else if self.foodUseCase.selectedKinds.isEmpty {
        } else {
            return filteredFoodArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        cell?.dateTextLabel.text = dateFormatter.string(from: Date())
//        if (self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator) && foodLocation.count != 0 {
//        if (self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator) && (self.filteredFoodArray != foods.getfoodArray()) {
        if (!self.foodUseCase.filterForFreezer && !self.foodUseCase.filterForRefrigerator) && (self.foodUseCase.selectedKinds.isEmpty) {
//            cell?.foodImage.image = UIImage(named: "\(filteredFoodArray[indexPath.row].kind.rawValue)")
//            cell?.preserveMethodTextLable.text = filteredFoodArray[indexPath.row].location.rawValue
//            cell?.foodNameTextLabel.text = filteredFoodArray[indexPath.row].name
//            cell?.quantityTextLabel.text = String(filteredFoodArray[indexPath.row].quantity)
//            cell?.unitTextLabel.text = filteredFoodArray[indexPath.row].unit.rawValue
            cell?.foodImage.image = UIImage(named: "\(foods.getfoodArray()[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = foods.getfoodArray()[indexPath.row].location.rawValue
            cell?.foodNameTextLabel.text = foods.getfoodArray()[indexPath.row].name
            cell?.quantityTextLabel.text = String(foods.getfoodArray()[indexPath.row].quantity)
            cell?.unitTextLabel.text = foods.getfoodArray()[indexPath.row].unit.rawValue
        } else {
            cell?.foodImage.image = UIImage(named: "\(filteredFoodArray[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = filteredFoodArray[indexPath.row].location.rawValue
            cell?.foodNameTextLabel.text = filteredFoodArray[indexPath.row].name
            cell?.quantityTextLabel.text = String(filteredFoodArray[indexPath.row].quantity)
            cell?.unitTextLabel.text = filteredFoodArray[indexPath.row].unit.rawValue
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
// 冷蔵、冷凍に応じて配列を入れるもの
//    func addFilteredFood() {
//        self.foodLocation.append(contentsOf: self.foods.filterationOfFood(with: foodUseCase.foodFilter))
//    }
    // 食材ボタンを押すとリストにそれを表示する
//    func foodSelect(boolOfKind: Bool, foodKind: Food.FoodKind) {
//        if boolOfKind && (self.foodUseCase.filterForRefrigerator || self.foodUseCase.filterForFreezer) {
//            self.foodLocationAndKind = []
//            self.foodLocationAndKind = self.foodLocation.filter {$0.kind == foodKind}
//        } else if !boolOfKind && (self.foodUseCase.filterForRefrigerator || self.foodUseCase.filterForFreezer) {
//            self.foodLocation
//        }
//    }
    // ボタンが押されたらfoodKindDic内のkey値を切り替える
//    func addFilteredByKinds(foodKind: Food.FoodKind) {
//        foodKindDictionary[foodKind]!.toggle()
//        let selectedKinds = foodKindDictionary.filter {$0.value == true}
//        let kinds = selectedKinds.map {$0.key}
//
//        foodUseCase.foodFilter.kind = kinds
//        self.foodfilteredbyKind = []
//        self.foodfilteredbyKind.append(contentsOf: self.foods.filterationOfFood(with: foodUseCase.foodFilter))
//    }
    // 冷蔵庫/冷凍庫用
    func switchLocation(targetLocation: Food.Location) {
//        var boolOfTargetLocation = boolOfTargetLocation
//        var boolOfAnotherLocation = boolOfAnotherLocation
//        boolOfTargetLocation.toggle()
//        boolOfAnotherLocation = false
        if foodUseCase.selectedKinds.isEmpty {
            self.filteredFoodArray = foods.getfoodArray()
        }
        foodUseCase.foodFilter.location = targetLocation
        foodUseCase.selectedKinds = []
        self.filteredFoodArray = filteredFoodArray.filter {$0.location == self.foodUseCase.foodFilter.location}
        if !foodUseCase.selectedKinds.isEmpty {
            self.filteredFoodArray = filteredFoodArray.filter {foodUseCase.foodFilter.kind.contains($0.kind) && $0.location == self.foodUseCase.foodFilter.location}
        }
        self.tableView.reloadData()
    }
//    func filterationOfFoodArray(foodKind: Food.FoodKind) {
    func filtrationOfFoodArray(kinds: [Food.FoodKind]) {
//        self.foodUseCase.foodKindDictionary[foodKind]!.toggle()
//        let selectedKinds = foodKindDictionary.filter {$0.value == true}
//        let kinds = selectedKinds.map {$0.key}
        self.foodUseCase.foodFilter.kind = kinds
        self.foodUseCase.selectedKinds = kinds
//        self.filteredFoodArray = foods.getfoodArray()
        self.filteredFoodArray = foods.getfoodArray().filter {foodUseCase.foodFilter.kind.contains($0.kind)}
        if self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator {
            self.filteredFoodArray = filteredFoodArray.filter {foodUseCase.foodFilter.kind.contains($0.kind) && $0.location == self.foodUseCase.foodFilter.location}
            print(filteredFoodArray)
        }
        if filteredFoodArray.isEmpty {
            self.filteredFoodArray = foods.getfoodArray()
        }
        self.tableView.reloadData()
    }
}
