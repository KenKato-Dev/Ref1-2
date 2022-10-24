//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FoodListViewController: UIViewController {

    private let sharedFoodUseCase = FoodUseCase.shared
    private let foodListPresenter = FoodListPresenter(foodData: FoodData())
//    private var foodLocation: [Food] = []
//    private var foodfilteredbyKind: [Food] = []
//    private var foodLocationAndKind: [Food] = []
//    private var filteredFoodArray: [Food] = []
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
//    private var isChange = true
//    var checkedIDDictionary: [String: Bool] = [:]
    // 配列を保持
//    private var foodArray: [Food] = []
    // 外部から参照だけできる
//    static private(set) var isEditMode: Bool = false
    let db = Firestore.firestore()

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
//        self.filteredFoodArray = self.foodArray
        self.foodListPresenter.setOutput(foodListPresenterOutput: self)

        self.foodListPresenter.didLoadView()
        // 削除ボタン
        deleteButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapDeleteButton()
        }), for: .touchUpInside)
        // 冷蔵庫ボタンのアクション
        self.filterRefrigeratorButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapRefrigiratorButton()
        }), for: .touchUpInside)
        // 冷凍庫ボタンのアクション
        self.filteredFreezerButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFreezerButton()
        }), for: .touchUpInside)
        // 食材ボタン
        self.filterForMeetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .meat)
        }), for: .touchUpInside)
        self.filterForFishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .fish)
        }), for: .touchUpInside)
        self.filterForVegAndFruitsButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .vegetableAndFruit)
        }), for: .touchUpInside)
        self.filterForMilkAndEggButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .milkAndEgg)
        }), for: .touchUpInside)
        self.filterForDishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .dish)
        }), for: .touchUpInside)
        self.filterForDrinkButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .drink)
        }), for: .touchUpInside)
        self.filterForSeasoningButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .seasoning)
        }), for: .touchUpInside)
        self.filterForSweetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .sweet)
        }), for: .touchUpInside)
        self.filterForOthersButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .other)
        }), for: .touchUpInside)

    }// viewdidload

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.foodListPresenter.willViewAppear()
    } // ViewWillAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.foodListPresenter.didLoadView()
    }
    // 下記にて遷移先のプロパティに代入
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "toRecepieTableView"{
            let recepieView = segue.destination as? RecepieCategoryListViewController
            recepieView?.navigationItem.title = String("\(sender!)")
//            recepieView?.searchKeyword = String("\(sender!)")
        }
    }

}
extension FoodListViewController: UITableViewDelegate, UITableViewDataSource {
    // Intでリストの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.foodListPresenter.numberOfRows()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        if (!self.sharedFoodUseCase.isFilteringFreezer &&
            !self.sharedFoodUseCase.isFilteringRefrigerator) &&
            (self.sharedFoodUseCase.selectedKinds.isEmpty) {
            if let food = foodListPresenter.foodInRow(forRow: indexPath.row) {
                cell?.foodConfigure(food: food)
            }
        } else {
            if let filteredFood = foodListPresenter.filteredFoodInRow(forRow: indexPath.row) {
                cell?.filteredConfigure(filteredFood: filteredFood)
            }
        }
        // 削除ボタンと連動
        cell?.showCheckBox = self.foodListPresenter.isDelete
        // UUIDをDictionaryに追加
        cell?.didTapCheckBox = self.foodListPresenter.isTapCheckboxButton(row: indexPath.row)
        // 下記エラー発生のため一時的にコメントアウト（2022/10/17）
        cell?.checkBoxButton.updateAppearance(isChecked: self.foodListPresenter.checkedID[self.foodListPresenter.array[indexPath.row].IDkey] ?? false)
        // 下記でcheckBoxの削除後に再利用されるCell内のBool値をfalseにする
        if self.foodListPresenter.isDelete {
            cell?.checkBoxButton.isTap = false
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inputView = self.storyboard?.instantiateViewController(withIdentifier: "modal") as? FoodAppendViewController

        // ここで選択しているセルにアクセス
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCell
        self.foodListPresenter.didSelectRow(storyboard: inputView, row: indexPath.row, foodNameTextLabel: cell?.foodNameTextLabel.text, quantityTextLabel: cell?.quantityTextLabel.text)
    }
}
extension FoodListViewController: UITextFieldDelegate {

}
extension FoodListViewController: FoodListPresenterOutput {
    func update() {
        self.tableView.reloadData()
    }
    func didRefreshSwipe() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addAction(.init(handler: { _ in
            self.foodListPresenter.loadArray()
            self.tableView.refreshControl?.endRefreshing()
        }), for: .valueChanged)
    }
    func isAppearingTrashBox(isDelete: Bool) {
        self.deleteButton.imageChange(bool: isDelete)
    }
    func present(inputView: FoodAppendViewController?) {
        if let inputView = inputView {
            self.present(inputView, animated: true)
        } else {
            print("presentのアンラップに失敗")
        }
    }
    func presentRecepie(alert: UIAlertController) {
        self.present(alert, animated: true) {
            print("エラー発生")
        }
    }
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    func performSegue(foodNameTextLabel: String?) {
        self.performSegue(withIdentifier: "toRecepieTableView", sender: foodNameTextLabel)
    }
}
