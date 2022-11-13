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

    private let foodListPresenter = FoodListPresenter(foodData: FoodData(), foodUseCase: FoodUseCase())

    @IBOutlet weak var addButtton: AddButton!
    @IBOutlet weak var locationButtonsStack: UIStackView!
    @IBOutlet weak var kindButtonsStack: UIStackView!
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
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.foodListPresenter.setOutput(foodListPresenterOutput: self)
        self.foodListPresenter.didLoadView()
        deleteButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapDeleteButton()
        }), for: .touchUpInside)
        self.filterRefrigeratorButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapRefrigiratorButton(self.filterRefrigeratorButton)
        }), for: .touchUpInside)
        self.filteredFreezerButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFreezerButton(self.filteredFreezerButton)
        }), for: .touchUpInside)
        self.filterForMeetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .meat)
            self.foodListPresenter.kindButtonAnimation(kind: .meat, self.filterForMeetButton)
        }), for: .touchUpInside)
        self.filterForFishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .fish)
            self.foodListPresenter.kindButtonAnimation(kind: .fish, self.filterForFishButton)
        }), for: .touchUpInside)
        self.filterForVegAndFruitsButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .vegetableAndFruit)
            self.foodListPresenter.kindButtonAnimation(kind: .vegetableAndFruit, self.filterForVegAndFruitsButton)
        }), for: .touchUpInside)
        self.filterForMilkAndEggButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .milkAndEgg)
            self.foodListPresenter.kindButtonAnimation(kind: .milkAndEgg, self.filterForMilkAndEggButton)
        }), for: .touchUpInside)
        self.filterForDishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .dish)
            self.foodListPresenter.kindButtonAnimation(kind: .dish, self.filterForDishButton)
        }), for: .touchUpInside)
        self.filterForDrinkButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .drink)
            self.foodListPresenter.kindButtonAnimation(kind: .drink, self.filterForDrinkButton)
        }), for: .touchUpInside)
        self.filterForSeasoningButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .seasoning)
            self.foodListPresenter.kindButtonAnimation(kind: .seasoning, self.filterForSeasoningButton)
        }), for: .touchUpInside)
        self.filterForSweetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .sweet)
            self.foodListPresenter.kindButtonAnimation(kind: .sweet, self.filterForSweetButton)
        }), for: .touchUpInside)
        self.filterForOthersButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .other)
            self.foodListPresenter.kindButtonAnimation(kind: .other, self.filterForOthersButton)
        }), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.foodListPresenter.willViewAppear()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.foodListPresenter.didLoadView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "toRecepieTableView"{
            let recepieView = segue.destination as? RecepieCategoryListViewController
            recepieView?.navigationItem.title = String("\(sender!)")
        }
    }
    }
extension FoodListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.foodListPresenter.numberOfRows()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configuredFood = self.foodListPresenter.isManagingArray(row: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        else {return .init()}
            cell.foodConfigure(food: configuredFood)
        let isChecked = self.foodListPresenter.checkedID[configuredFood.IDkey] ?? false
        let shouldShowCheckBox = !self.foodListPresenter.isDelete
        if shouldShowCheckBox {
            cell.configure(state: .shownCheckBox(isChecked: isChecked))
        } else {
            cell.configure(state: .normal)
        }
        cell.didTapCheckBox = self.foodListPresenter.isTapCheckboxButton(row: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inputView = self.storyboard?.instantiateViewController(withIdentifier: "modal") as? FoodAppendViewController
        // ここで選択しているセルにアクセス
        tableView.deselectRow(at: indexPath, animated: false)
        self.foodListPresenter.didSelectRow(storyboard: inputView, row: indexPath.row)
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
    func presentAlert(alert: UIAlertController) {
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
    func setTitle(refigerator: Bool, freezer: Bool, selectedKinds: [Food.FoodKind], location: Food.Location) {
        // この処理でなく条件式も含めタイトルを入れるようにする
        if (!refigerator &&
            !freezer)&&(selectedKinds.isEmpty) {
            self.viewTitle.title = "冷蔵品と冷凍品"

        } else {
            if location == .refrigerator {
                self.viewTitle.title  = "冷蔵品"
            } else if location == .freezer {
                self.viewTitle.title  = "冷凍品"
            }
        }
    }
    func isHidingButtons(isDelete: Bool) {
        self.addButtton.isEnabled = isDelete
        self.locationButtonsStack.isHidden = !isDelete
        self.kindButtonsStack.isHidden = !isDelete
        if !isDelete {
            self.locationButtonsStack.backgroundColor = .clear
            self.kindButtonsStack.backgroundColor = .clear
            self.tableViewBottomConstraint.constant = 165
        } else {
            self.locationButtonsStack.backgroundColor = .clear
            self.kindButtonsStack.backgroundColor = .white
            self.tableViewBottomConstraint.constant = 0
        }
    }
    func buttonAnimation(isFilteringRef: Bool, isFilteringFreezer: Bool) {
        if isFilteringRef {
            self.filterRefrigeratorButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            self.filterRefrigeratorButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        if isFilteringFreezer {
            self.filteredFreezerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            self.filteredFreezerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
