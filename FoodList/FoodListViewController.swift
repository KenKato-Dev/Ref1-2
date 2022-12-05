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
    @IBOutlet weak var kindButtonsBackView: UIView!
    @IBOutlet var refrigeratorButton: UIButton!
    @IBOutlet var freezerButton: UIButton!
    @IBOutlet var meatButton: UIButton!
    @IBOutlet var fishButton: UIButton!
    @IBOutlet var vegitableFruitsButton: UIButton!
    @IBOutlet var milkEggButton: UIButton!
    @IBOutlet var dishButton: UIButton!
    @IBOutlet var drinkButton: UIButton!
    @IBOutlet var seasoningButton: UIButton!
    @IBOutlet var sweetButton: UIButton!
    @IBOutlet var othersButton: UIButton!
    @IBOutlet var foodListTableView: UITableView!
    @IBOutlet var viewTitle: UINavigationItem!
    @IBOutlet var deleteButton: DeleteButton!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        foodListTableView.delegate = self
        foodListTableView.dataSource = self
        foodListPresenter.setOutput(foodListPresenterOutput: self)
        foodListPresenter.isLoadingList()
        deleteButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapDeleteButton()
        }), for: .touchUpInside)
        refrigeratorButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapRefrigiratorButton(self.refrigeratorButton)
        }), for: .touchUpInside)
        freezerButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFreezerButton(self.freezerButton)
        }), for: .touchUpInside)
        meatButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.meat, self.meatButton)
        }), for: .touchUpInside)
        fishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.fish, self.fishButton)
        }), for: .touchUpInside)
        vegitableFruitsButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.vegetableAndFruit, self.vegitableFruitsButton)
        }), for: .touchUpInside)
        milkEggButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.milkAndEgg, self.milkEggButton)
        }), for: .touchUpInside)
        dishButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.dish, self.dishButton)
        }), for: .touchUpInside)
        drinkButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.drink, self.drinkButton)
        }), for: .touchUpInside)
        seasoningButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.seasoning, self.seasoningButton)
        }), for: .touchUpInside)
        sweetButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.sweet, self.sweetButton)
        }), for: .touchUpInside)
        othersButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapFoodKindButtons(.other, self.othersButton)
        }), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodListPresenter.isLoadingList()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foodListPresenter.isLoadingList()
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
        cell.foodConfigure(food: configuredFood)
//        cell.isUserInteractionEnabled = self.foodListPresenter.isDelete
//        cell.disableSelectCell(self.foodListPresenter.isDelete)
//        cell.checkBoxButton.isEnabled = !self.foodListPresenter.isDelete
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
extension FoodListViewController: FoodListPresenterOutput {
    func reloadData() {
        foodListTableView.reloadData()
    }
//    func present1(_ inputView: FoodAppendViewController?) {
//        if let inputView = inputView {
//            present(inputView, animated: true)
//        } else {
//            print("presentのアンラップに失敗")
//        }
//    }
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true) {
        }
    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
//    func performSegue1(_ foodNameTextLabel: String?) {
//        performSegue(withIdentifier: "toRecepieTableView", sender: foodNameTextLabel)
//    }
    func setTitle(_ refigerator: Bool, _ freezer: Bool, _ selectedKinds: [Food.FoodKind], _ location: Food.Location) {
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

    func didTapDeleteButton(_ isDelete: Bool) {
        deleteButton.imageChange(bool: isDelete)
        addButtton.isEnabled = isDelete
        locationButtonsStack.isHidden = !isDelete
        kindButtonsStack.isHidden = !isDelete
        kindButtonsBackView.isHidden = !isDelete
        scrollView.isHidden = !isDelete
        self.meatButton.isHidden = !isDelete
        self.fishButton.isHidden = !isDelete
        self.vegitableFruitsButton.isHidden = !isDelete
        self.milkEggButton.isHidden = !isDelete
        self.dishButton.isHidden = !isDelete
        self.drinkButton.isHidden = !isDelete
        self.seasoningButton.isHidden = !isDelete
        self.sweetButton.isHidden = !isDelete
        self.othersButton.isHidden = !isDelete
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
    func animateButton(_ isFilteringRef: Bool, _ isFilteringFreezer: Bool) {
        if isFilteringRef {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        if isFilteringFreezer {
            freezerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            freezerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    func resetButtonColor() {
        self.meatButton.setImage(UIImage(named: "meatButton"), for: .normal)
        self.meatButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.fishButton.setImage(UIImage(named: "fishButton"), for: .normal)
        self.fishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.vegitableFruitsButton.setImage(UIImage(named: "vegetableAndFruitButton"), for: .normal)
        self.vegitableFruitsButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.milkEggButton.setImage(UIImage(named: "milkAndEggButton"), for: .normal)
        self.milkEggButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.dishButton.setImage(UIImage(named: "dishButton"), for: .normal)
        self.dishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.drinkButton.setImage(UIImage(named: "drinkButton"), for: .normal)
        self.drinkButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.seasoningButton.setImage(UIImage(named: "seasoningButton"), for: .normal)
        self.seasoningButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.sweetButton.setImage(UIImage(named: "sweetButton"), for: .normal)
        self.sweetButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.othersButton.setImage(UIImage(named: "otherButton"), for: .normal)
        self.othersButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    func showAlertInCell(_ storyboard: FoodAppendViewController?, _ array: [Food], _ row: Int) {
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        // アラートアクションシート一項目目
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { [self] _ in
            let inputView = storyboard
            guard let inputView = inputView,
                  let modalImput = inputView.sheetPresentationController else {return}
            modalImput.detents = [.medium()]

            present(inputView, animated: true)
            // 共通部分をここに収める
            inputView.kindSelectText.isHidden = true
            inputView.unitSelectButton.isEnabled = false
            inputView.unitSelectButton.alpha = 1.0
            // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
            inputView.foodKindsStacks.isHidden = true
            inputView.parentStacKView.spacing = 50
            inputView.nameTextHeightconstraint.constant = 20
            inputView.quantityTextHeightConstraint.constant = 20
            if FoodListPresenter.isTapRow {

                inputView.unitSelectButton.setTitle(inputView.unitSelectButton.unitButtonTranslator(unit: array[row].unit), for: .normal)
                inputView.foodNameTextField.text = array[row].name
                inputView.quantityTextField.text = array[row].quantity
                if !inputView.foodNameTextField.text!.isEmpty && !inputView.quantityTextField.text!.isEmpty {
                    inputView.preserveButton.isEnabled = true
                } else {
                    inputView.preserveButton.isEnabled = false
                }
                var locationString = ""
                inputView.refrigeratorButton.addAction(.init(handler: { _ in
                    // Model→Presenter→ここ
                    locationString = Food.Location.refrigerator.rawValue
                    self.foodListPresenter.setLocationInInputView(row, locationString: locationString)
                }), for: .touchUpInside)
                inputView.freezerButton.addAction(.init(handler: { _ in
                    locationString = Food.Location.freezer.rawValue
                    self.foodListPresenter.setLocationInInputView(row, locationString: locationString)
                }), for: .touchUpInside)
            }
                inputView.preserveButton.addAction(.init(handler: { [self] _ in

                    if inputView.foodNameTextField.text!.isEmpty {
                        inputView.foodNameTextField.attributedPlaceholder = NSAttributedString(string: "名称を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                    }
                    if inputView.quantityTextField.text!.isEmpty {
                        inputView.quantityTextField.attributedPlaceholder = NSAttributedString(string: "数量を入れてください", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                    if !inputView.foodNameTextField.text!.isEmpty && !inputView.quantityTextField.text!.isEmpty {
                        self.foodListPresenter.didTapPreserveOnInputView(foodName: inputView.foodNameTextField.text, foodQuantity: inputView.quantityTextField.text, foodinArray: array[row])
                    }
//                    self.foodListPresenter.resetIsTapRow()
                }), for: .touchUpInside)
        }))
        // アラートアクションシート二項目目
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "toRecepieTableView", sender: array[row].name)
//            self.foodListPresenter.resetIsTapRow()
        }))
        // アラートアクションシート三項目目
        alert.addAction(.init(title: "キャンセル", style: .destructive, handler: { _ in
//            self.foodListPresenter.resetIsTapRow()
        }))
        self.foodListPresenter.resetIsTapRow()
        present(alert, animated: true)
    }
    func showDeleteAlert() {
        // 削除するかどうかアラート
        let alert = UIAlertController(title: "削除しますか?", message: "", preferredStyle: .actionSheet)
        alert.addAction(.init(title: "はい", style: .default, handler: { _ in
            self.foodListPresenter.deleteAction()
            self.reloadData()
        }))
        alert.addAction(.init(title: "いいえ", style: .destructive, handler: { _ in
            self.foodListPresenter.resetCheckedID()
            print("削除をキャンセル")
        }))
        present(alert, animated: true)
    }
}
