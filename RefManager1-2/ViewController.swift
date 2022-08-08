//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private var foods = FoodData.shared
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
    var checkedIDDictionary: [String: Bool] = [:]
    // 配列を保持
    private var foodArray: [Food] = []
    // 外部から参照だけできる
    static private(set) var isEditMode: Bool = false
    let db = Firestore.firestore()

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.filteredFoodArray = self.foodArray

        foods.fetchFoods { result in
            switch result {
            case .success(let foods):
                self.foodArray = foods
                // ここに入れることで起動時に表示
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        // 削除ボタン
        deleteButton.addAction(.init(handler: { _ in
            self.isChange.toggle()
            self.deleteButton.imageChange(bool: self.isChange)
            // 再度タップしてisChangeがfalseに切り替わった際の挙動、Bool値がTrueに設定
            if self.isChange {
                // filterで値のみを取り出し、defoはTrueを取り出すため
                let filteredIDictionary = self.checkedIDDictionary.filter {$0.value}.map {$0.key}
//                    self.foods.delete(filteredIDictionary)
                self.foods.delete(filteredIDictionary) { result in
                    switch result {
                    case.success:
                        // ここから
                        self.checkedIDDictionary = [:]
                        self.foods.fetchFoods { result in
                            switch result {
                            case .success(let foods):
                                self.foodArray = foods
                                // このReloadにより削除がtableに反映
                                self.tableView.reloadData()
                            case .failure(let error):
                                print(error)
                            }
                            // 下記reloadがないと表示が反映されず1
                            self.tableView.reloadData()
                        }
                        // ここまで切り取り（78）
                    case.failure(let error):
                        print(error)
                    }
                }

                // 下記reloadがないと表示が反映されず2
                self.tableView.reloadData()
            }
            // 下記reloadでチェックボックス出現
                self.tableView.reloadData()
//            }
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
        // 食材ボタン
        self.filterForMeetButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.meat]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForFishButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.fish]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForVegAndFruitsButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.vegetableAndFruit]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForMilkAndEggButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.milkAndEgg]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForDishButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.dish]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForDrinkButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.drink]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForSeasoningButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.seasoning]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForSweetButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.sweet]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.filterForOthersButton.addAction(.init(handler: { _ in
            self.foodUseCase.foodKindDictionary[.other]!.toggle()
            let selectedKinds = self.foodUseCase.foodKindDictionary.filter {$0.value == true}
            let kinds = selectedKinds.map {$0.key}
            print(kinds)
            self.filtrationOfFoodArray(kinds: kinds)
            self.tableView.reloadData()
        }), for: .touchUpInside)
        self.tableView.reloadData()
    }// viewdidload

    // ViewwillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addAction(.init(handler: { _ in
            self.foods.fetchFoods { result in
                switch result {
                case .success(let foods):
                    self.foodArray = foods
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
            self.tableView.refreshControl?.endRefreshing()
        }), for: .valueChanged)
        self.tableView.reloadData()
    } // ViewWillAppear
    override func viewDidAppear(_ animated: Bool) {
        foods.fetchFoods { result in
            switch result {
            case .success(let foods):
                self.foodArray = foods
                // ここに入れることで起動時に表示
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    // Intでリストの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!foodUseCase.filterForFreezer && !foodUseCase.filterForRefrigerator) && (self.foodUseCase.selectedKinds.isEmpty) {
            // Cellの数が返ってこず、Optional(0)となっている
            // fetchCountForTestでも値は返ってくるがまず初めに初期値設定したIntが入りそれを元にTableが構築される
            return self.foodArray.count
        } else {
            return filteredFoodArray.count
        }
    }
    // cellの中身を記述
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        if (!self.foodUseCase.filterForFreezer && !self.foodUseCase.filterForRefrigerator) && (self.foodUseCase.selectedKinds.isEmpty) {
            cell?.foodImage.image = UIImage(named: "\(self.foodArray[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = locationTranslator(location: self.foodArray[indexPath.row].location)
            cell?.foodNameTextLabel.text = self.foodArray[indexPath.row].name
            cell?.quantityTextLabel.text = String(self.foodArray[indexPath.row].quantity)
            cell?.unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: self.foodArray[indexPath.row].unit)
            cell?.dateTextLabel.text = self.foodArray[indexPath.row].date.formatted(date: .abbreviated, time: .omitted)
        } else {
            cell?.foodImage.image = UIImage(named: "\(filteredFoodArray[indexPath.row].kind.rawValue)")
            cell?.preserveMethodTextLable.text = locationTranslator(location: filteredFoodArray[indexPath.row].location)
            cell?.foodNameTextLabel.text = filteredFoodArray[indexPath.row].name
            cell?.quantityTextLabel.text = String(filteredFoodArray[indexPath.row].quantity)
            cell?.unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: filteredFoodArray[indexPath.row].unit)
            cell?.dateTextLabel.text = filteredFoodArray[indexPath.row].date.formatted(date: .abbreviated, time: .omitted)
        }
        // 削除ボタンと連動
        cell?.showCheckBox = self.isChange
        // UUIDをDictionaryに追加
        cell?.didTapCheckBox = { isChecked in
            self.checkedIDDictionary[self.foodArray[indexPath.row].IDkey] = isChecked
            print(self.checkedIDDictionary)
        }
        cell?.checkBoxButton.updateAppearance(isChecked: checkedIDDictionary[self.foodArray[indexPath.row].IDkey] ?? false)
        // 下記でcheckBoxの削除後に再利用されるCell内のBool値をfalseにする
        if !isChange {
            cell?.checkBoxButton.isTap = false
        }
        return cell!
    } // indexpath

    // ここでCellが選択された時の内容を記述、StoryboardにてSingleSelectionDuringEditingを選択
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ここで選択しているセルにアクセス
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        let inputView = storyboard?.instantiateViewController(withIdentifier: "modal") as? ModalViewController
//        let imputView = ModalViewController()
        if let modalImput = inputView?.sheetPresentationController {
            modalImput.detents = [.medium()]
        } else {
            print("エラーです")
        }
        present(inputView!, animated: true)
        inputView?.kindSelectText.isHidden = true
        inputView?.unitSelectButton.setTitle(inputView?.unitSelectButton.unitButtonTranslator(unit: self.foodArray[indexPath.row].unit), for: .normal)
        inputView?.unitSelectButton.isEnabled = false
        inputView?.unitSelectButton.alpha = 1.0
//        "\(self.foodArray[indexPath.row].unit)"
        // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
        inputView?.foodKindsStacks.isHidden = true
        inputView?.parentStacKView.spacing = 50
        inputView?.nameTextHeightconstraint.constant = 20
        inputView?.quantityTextHeightConstraint.constant = 20

//        inputView?.nameTextHeightconstraint.multiplier = 0.1
        inputView?.foodNameTextField.delegate = self
        inputView?.quantityTextField.delegate = self
        ViewController.isEditMode = true

        if ViewController.isEditMode == true {
            inputView?.preserveButton.addAction(.init(handler: { [self]_ in
                cell?.foodNameTextLabel.text = inputView?.foodNameTextField.text
                cell?.quantityTextLabel.text = inputView?.quantityTextField.text
                print("inputのアクションが操作")
                self.db.collection("foods").document("IDkey: \(self.foodArray[indexPath.row].IDkey)").setData([
                    "name": "\((inputView?.foodNameTextField.text)!)",
                    "quantity": "\((inputView?.quantityTextField.text)!)",
                    "date": "\(Date())",
                    "IDkey": "\(self.foodArray[indexPath.row].IDkey)",
                    "kind": "\(self.foodArray[indexPath.row].kind)",
                    "unit": "\(self.foodArray[indexPath.row].unit)"
                ], merge: true) { err in
                    if let err = err {
                        print("FireStoreへの書き込みに失敗しました: \(err)")
                        ViewController.isEditMode = false
                    } else {
                        print("FireStoreへの書き込みに成功しました")
                        ViewController.isEditMode = false
                    }
                }
                self.dismiss(animated: true, completion: nil)
                ViewController.isEditMode = false
                // ここで読み込む
                foods.fetchFoods { result in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        switch result {
                        case .success(let foods):
                            self.foodArray = foods
                            // ここに入れることで起動時に表示
                            self.tableView.reloadData()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }), for: .touchUpInside)
            inputView?.refrigeratorButton.addAction(.init(handler: { _ in
                self.db.collection("foods").document("IDkey: \(self.foodArray[indexPath.row].IDkey)").setData([
                    "location": "\(Food.Location.refrigerator.rawValue)"
                ])
                print("\(Food.Location.refrigerator.rawValue)")
            }), for: .touchUpInside)
            inputView?.freezerButton.addAction(.init(handler: { _ in
                self.db.collection("foods").document("IDkey: \(self.foodArray[indexPath.row].IDkey)").setData([
                    "location": "\(Food.Location.freezer.rawValue)"
                ])
                print("\(Food.Location.freezer.rawValue)")
            }), for: .touchUpInside)
//            inputView?.unitSelectButton.addAction(.init(handler: { _ in
//                self.db.collection("foods").document("IDkey: \(self.foodArray[indexPath.row].IDkey)").setData([
//                    "location": "\(self.foodArray[indexPath.row].unit)"
//                ])
//            }), for: .allTouchEvents)
        }
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
//        print("didDeselectRowAt")
//    }
    // 冷蔵庫/冷凍庫用
    func switchLocation(targetLocation: Food.Location) {
        if foodUseCase.selectedKinds.isEmpty {
            self.filteredFoodArray = self.foodArray
        }
        foodUseCase.foodFilter.location = targetLocation
        foodUseCase.selectedKinds = []
        self.filteredFoodArray = filteredFoodArray.filter {$0.location == self.foodUseCase.foodFilter.location}
        if !foodUseCase.selectedKinds.isEmpty {
            self.filteredFoodArray = filteredFoodArray.filter {foodUseCase.foodFilter.kind.contains($0.kind) && $0.location == self.foodUseCase.foodFilter.location}
        }
        self.tableView.reloadData()
    }
    func filtrationOfFoodArray(kinds: [Food.FoodKind]) {
        self.foodUseCase.foodFilter.kind = kinds
        self.foodUseCase.selectedKinds = kinds
        self.filteredFoodArray = self.foodArray.filter {foodUseCase.foodFilter.kind.contains($0.kind)}
        if self.foodUseCase.filterForFreezer || self.foodUseCase.filterForRefrigerator {
            self.filteredFoodArray = filteredFoodArray.filter {foodUseCase.foodFilter.kind.contains($0.kind) && $0.location == self.foodUseCase.foodFilter.location}
            print(filteredFoodArray)
        }
        if filteredFoodArray.isEmpty {
            self.filteredFoodArray = self.foodArray
        }
        self.tableView.reloadData()
    }
    func locationTranslator(location: Food.Location) -> String {
        var trasnlatedlocation = String()
        if location == .refrigerator {
            trasnlatedlocation = "冷蔵"
        } else if location == .freezer {
            trasnlatedlocation = "冷凍"
        }
        return trasnlatedlocation
    }
}
