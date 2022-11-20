//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

final class FoodListViewController: UIViewController {
    private let foodListPresenter = FoodListPresenter(foodData: FoodData(), foodUseCase: FoodUseCase())

    @IBOutlet var addButtton: AddButton!
    @IBOutlet var locationButtonsStack: UIStackView!
    @IBOutlet var kindButtonsStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var kindButtonsBackgroundView: UIView!
    @IBOutlet var filterRefrigeratorButton: UIButton!
    @IBOutlet var filteredFreezerButton: UIButton!
    @IBOutlet var filterForMeetButton: UIButton!
    @IBOutlet var filterForFishButton: UIButton!
    @IBOutlet var filterForVegAndFruitsButton: UIButton!
    @IBOutlet var filterForMilkAndEggButton: UIButton!
    @IBOutlet var filterForDishButton: UIButton!
    @IBOutlet var filterForDrinkButton: UIButton!
    @IBOutlet var filterForSeasoningButton: UIButton!
    @IBOutlet var filterForSweetButton: UIButton!
    @IBOutlet var filterForOthersButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewTitle: UINavigationItem!
    @IBOutlet var deleteButton: DeleteButton!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        foodListPresenter.setOutput(foodListPresenterOutput: self)
        foodListPresenter.didLoadView()
        deleteButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapDeleteButton()
        }), for: .touchUpInside)
        filterRefrigeratorButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapRefrigiratorButton(self.filterRefrigeratorButton)
        }), for: .touchUpInside)
        filteredFreezerButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFreezerButton(self.filteredFreezerButton)
        }), for: .touchUpInside)
        filterForMeetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .meat)
            self.foodListPresenter.kindButtonAnimation(kind: .meat, self.filterForMeetButton)
        }), for: .touchUpInside)
        filterForFishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .fish)
            self.foodListPresenter.kindButtonAnimation(kind: .fish, self.filterForFishButton)
        }), for: .touchUpInside)
        filterForVegAndFruitsButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .vegetableAndFruit)
            self.foodListPresenter.kindButtonAnimation(kind: .vegetableAndFruit, self.filterForVegAndFruitsButton)
        }), for: .touchUpInside)
        filterForMilkAndEggButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .milkAndEgg)
            self.foodListPresenter.kindButtonAnimation(kind: .milkAndEgg, self.filterForMilkAndEggButton)
        }), for: .touchUpInside)
        filterForDishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .dish)
            self.foodListPresenter.kindButtonAnimation(kind: .dish, self.filterForDishButton)
        }), for: .touchUpInside)
        filterForDrinkButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .drink)
            self.foodListPresenter.kindButtonAnimation(kind: .drink, self.filterForDrinkButton)
        }), for: .touchUpInside)
        filterForSeasoningButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .seasoning)
            self.foodListPresenter.kindButtonAnimation(kind: .seasoning, self.filterForSeasoningButton)
        }), for: .touchUpInside)
        filterForSweetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .sweet)
            self.foodListPresenter.kindButtonAnimation(kind: .sweet, self.filterForSweetButton)
        }), for: .touchUpInside)
        filterForOthersButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(kind: .other)
            self.foodListPresenter.kindButtonAnimation(kind: .other, self.filterForOthersButton)
        }), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodListPresenter.willViewAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foodListPresenter.didViewAppear()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecepieTableView" {
            let recepieView = segue.destination as? RecepieCategoryListViewController
            recepieView?.navigationItem.title = String("\(sender!)")
        }
    }
}

extension FoodListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        foodListPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configuredFood = foodListPresenter.isManagingArray(row: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        else { return .init() }
//        print("row:\(indexPath.row)")
        cell.foodConfigure(food: configuredFood)
        let isChecked = foodListPresenter.checkedID[configuredFood.IDkey] ?? false
        let shouldShowCheckBox = !foodListPresenter.isDelete
        if shouldShowCheckBox {
            cell.configure(state: .shownCheckBox(isChecked: isChecked))
        } else {
            cell.configure(state: .normal)
        }
        cell.didTapCheckBox = foodListPresenter.isTapCheckboxButton(row: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inputView = storyboard?.instantiateViewController(withIdentifier: "modal") as? FoodAppendViewController
        // ここで選択しているセルにアクセス
        tableView.deselectRow(at: indexPath, animated: false)
        foodListPresenter.didSelectRow(storyboard: inputView, row: indexPath.row)
    }
        // スクロールし、indexPathのセルが表示される直前に呼ばれる
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        self.foodListPresenter.didScrollToLast(row: indexPath.row)
    }
}

extension FoodListViewController: UITextFieldDelegate {}

extension FoodListViewController: FoodListPresenterOutput {
    func update() {
        tableView.reloadData()
    }

//    func didRefreshSwipe() {
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl?.addAction(.init(handler: { _ in
//            self.foodListPresenter.loadArray()
//            self.tableView.refreshControl?.endRefreshing()
//        }), for: .valueChanged)
//    }

    func isAppearingTrashBox(isDelete: Bool) {
        deleteButton.imageChange(bool: isDelete)
    }

    func present(inputView: FoodAppendViewController?) {
        if let inputView = inputView {
            present(inputView, animated: true)
        } else {
            print("presentのアンラップに失敗")
        }
    }

    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true) {
            print("エラー発生")
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func performSegue(foodNameTextLabel: String?) {
        performSegue(withIdentifier: "toRecepieTableView", sender: foodNameTextLabel)
    }

    func setTitle(refigerator: Bool, freezer: Bool, selectedKinds: [Food.FoodKind], location: Food.Location) {
        // この処理でなく条件式も含めタイトルを入れるようにする
        if !refigerator,
           !freezer, selectedKinds.isEmpty {
            viewTitle.title = "冷蔵品と冷凍品"

        } else {
            if location == .refrigerator {
                viewTitle.title = "冷蔵品"
            } else if location == .freezer {
                viewTitle.title = "冷凍品"
            }
        }
    }

    func isHidingButtons(isDelete: Bool) {
        addButtton.isEnabled = isDelete
        locationButtonsStack.isHidden = !isDelete
        kindButtonsStack.isHidden = !isDelete
        kindButtonsBackgroundView.isHidden = !isDelete
        scrollView.isHidden = !isDelete
        self.filterForMeetButton.isHidden = !isDelete
        self.filterForFishButton.isHidden = !isDelete
        self.filterForVegAndFruitsButton.isHidden = !isDelete
        self.filterForMilkAndEggButton.isHidden = !isDelete
        self.filterForDishButton.isHidden = !isDelete
        self.filterForDrinkButton.isHidden = !isDelete
        self.filterForSeasoningButton.isHidden = !isDelete
        self.filterForSweetButton.isHidden = !isDelete
        self.filterForOthersButton.isHidden = !isDelete
        if !isDelete {
            locationButtonsStack.backgroundColor = .clear
            kindButtonsStack.backgroundColor = .clear
            tableViewBottomConstraint.constant = 165
        } else {
            locationButtonsStack.backgroundColor = .clear
            kindButtonsStack.backgroundColor = .white
            tableViewBottomConstraint.constant = 0
        }
    }

    func animateButton(isFilteringRef: Bool, isFilteringFreezer: Bool) {
        if isFilteringRef {
            filterRefrigeratorButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            filterRefrigeratorButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        if isFilteringFreezer {
            filteredFreezerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            filteredFreezerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    func resetButtonColor() {
        self.filterForMeetButton.backgroundColor = .clear
        self.filterForMeetButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForFishButton.backgroundColor = .clear
        self.filterForFishButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForVegAndFruitsButton.backgroundColor = .clear
        self.filterForVegAndFruitsButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForMilkAndEggButton.backgroundColor = .clear
        self.filterForMilkAndEggButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForDishButton.backgroundColor = .clear
        self.filterForDishButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForDrinkButton.backgroundColor = .clear
        self.filterForDrinkButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForSeasoningButton.backgroundColor = .clear
        self.filterForSeasoningButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForSweetButton.backgroundColor = .clear
        self.filterForSweetButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.filterForOthersButton.backgroundColor = .clear
        self.filterForOthersButton.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
}
