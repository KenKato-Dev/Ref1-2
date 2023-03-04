//
//  ViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleMobileAds
import UIKit
// FoodListVIewVC
final class FoodListViewController: UIViewController {
    private let foodListPresenter = FoodListPresenter(foodData: FoodData(), foodUseCase: FoodUseCase())
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var addButtton: AddButton!
    @IBOutlet var deleteButton: DeleteButton!
    @IBOutlet var locationButtonsStack: UIStackView!
    @IBOutlet var kindButtonsStack: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var kindButtonsBackView: UIView!
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
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bannerView: GADBannerView!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()

    private var userNameLabel = UILabel()
    private let recommendToAddLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodListTableView.delegate = self
        foodListTableView.dataSource = self
        foodListPresenter.setOutput(foodListPresenterOutput: self)
        foodListPresenter.displayBanner()
        foodListPresenter.displayTitle()
        foodListPresenter.displayIndicator()
        foodListPresenter.fetchArray()
        // 各種ボタン操作
        deleteButton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapDeleteButton()
        }), for: .touchUpInside)
        addButtton.addAction(.init(handler: { _ in
            self.foodListPresenter.didTapAddButton()
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
        foodListPresenter.fetchArray()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foodListPresenter.fetchArray()
    }

    // performsegueと連動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecipeTableView" {
            let recipeView = segue.destination as? RecipeCategoryListViewController
            recipeView?.navigationItem.title = String("\(sender!)")
        }
    }
}

extension FoodListViewController: UITableViewDelegate, UITableViewDataSource {
    // cellの数

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        foodListPresenter.numberOfRows()
    }

    // cellの中身の表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let foodInRow = foodListPresenter.refreshArrayIfNeeded(row: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FoodListCell
        else { return .init() }
        cell.composeFood(food: foodInRow)
        let isCheckedDictionary = foodListPresenter.checkedID[foodInRow.IDkey] ?? false
        let shouldShowCheckBox = !foodListPresenter.isDelete
        if shouldShowCheckBox {
            cell.controllCheckBox(state: .shownCheckBox(isChecked: isCheckedDictionary))
        } else {
            cell.controllCheckBox(state: .normal)
        }

        cell.didTapCheckBox = foodListPresenter.setArgInDidTapCheckBox(at: indexPath.row)
        return cell
    }

    // cell選択時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let updationView = storyboard?.instantiateViewController(withIdentifier: "modal") as? FoodAppendViewController
        // ここで選択しているセルにアクセス
        tableView.deselectRow(at: indexPath, animated: false)
        foodListPresenter.didSelectRow(storyboard: updationView, row: indexPath.row)
    }

    // スクロールし、indexPathのセルが表示される直前に呼ばれる
    func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        foodListPresenter.didScrollToLast(row: indexPath.row)
    }
}

// Presenter側で定義したOutputに準拠した拡張
extension FoodListViewController: FoodListPresenterOutput {
    // tableのリロード
    func reloadData() {
        foodListTableView.reloadData()
    }

    // エラー表示
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {}
    }

    // viewのdismiss
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    // navigationItemのタイトルをBool値に応じて変更、色が変わらず要改善
    func setTitle(_ refigerator: Bool, _ freezer: Bool, _ selectedKinds: [Food.FoodKind], _ location: Food.Location) {
        // この処理でなく条件式も含めタイトルを入れるようにする
        if !refigerator,
           !freezer, selectedKinds.isEmpty {
            viewTitle.title = "冷蔵品と冷凍品"
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 20)]

        } else {
            if location == .refrigerator {
                viewTitle.title = "冷蔵品"
                navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "ref"), .font: UIFont.systemFont(ofSize: 20)]
            } else if location == .freezer {
                viewTitle.title = "冷凍品"
                navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "freezer"), .font: UIFont.systemFont(ofSize: 20)]
            }
        }
    }

    // 削除ボタンを押した際の処理
    func arrangeDisplayingView(_ isDelete: Bool) {
        deleteButton.imageChange(bool: isDelete)
        addButtton.isEnabled = isDelete
        accountButton.isEnabled = isDelete
        locationButtonsStack.isHidden = !isDelete
        kindButtonsStack.isHidden = !isDelete
        kindButtonsBackView.isHidden = !isDelete
        scrollView.isHidden = !isDelete
        meatButton.isHidden = !isDelete
        fishButton.isHidden = !isDelete
        vegitableFruitsButton.isHidden = !isDelete
        milkEggButton.isHidden = !isDelete
        dishButton.isHidden = !isDelete
        drinkButton.isHidden = !isDelete
        seasoningButton.isHidden = !isDelete
        sweetButton.isHidden = !isDelete
        othersButton.isHidden = !isDelete
        if !isDelete {
            locationButtonsStack.backgroundColor = .clear
            kindButtonsStack.backgroundColor = .clear
            tableViewBottomConstraint.constant = -100

        } else {
            locationButtonsStack.backgroundColor = .clear
            kindButtonsStack.backgroundColor = .clear
            tableViewBottomConstraint.constant = 5
        }
    }

    // 保管場所のボタンを押した際のアニメーション
    func animateLocationButton(_ isFilteringRef: Bool, _ isFilteringFreezer: Bool) {
        if isFilteringRef {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            refrigeratorButton.tintColor = .gray
            refrigeratorButton.configuration?.background.backgroundColor = UIColor(named: "refSelected") //
        } else {
            refrigeratorButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            refrigeratorButton.tintColor = .white
            refrigeratorButton.configuration?.background.backgroundColor = UIColor(named: "ref")
        }
        if isFilteringFreezer {
            freezerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            freezerButton.tintColor = UIColor(named: "freezerSelected")
            freezerButton.configuration?.background.backgroundColor = .lightGray //
        } else {
            freezerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            freezerButton.tintColor = .white
            freezerButton.configuration?.background.backgroundColor = .white //
        }
    }

    // 押したボタンのイメージと大きさを初期化
    func resetButtonColor() {
        meatButton.setImage(UIImage(named: "meatButton"), for: .normal)
        meatButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        fishButton.setImage(UIImage(named: "fishButton"), for: .normal)
        fishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        vegitableFruitsButton.setImage(UIImage(named: "vegetableAndFruitButton"), for: .normal)
        vegitableFruitsButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        milkEggButton.setImage(UIImage(named: "milkAndEggButton"), for: .normal)
        milkEggButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        dishButton.setImage(UIImage(named: "dishButton"), for: .normal)
        dishButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        drinkButton.setImage(UIImage(named: "drinkButton"), for: .normal)
        drinkButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        seasoningButton.setImage(UIImage(named: "seasoningButton"), for: .normal)
        seasoningButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        sweetButton.setImage(UIImage(named: "sweetButton"), for: .normal)
        sweetButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        othersButton.setImage(UIImage(named: "otherButton"), for: .normal)
        othersButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }

    // cell選択時に表示するアラートを表示
    func showAlertInCell(_ storyboard: FoodAppendViewController?, _ array: [Food], _ row: Int, _ isTapRow: Bool) {
        let alert = UIAlertController(title: "選択してください", message: "", preferredStyle: .actionSheet)
        // アラートアクションシート一項目目
        alert.addAction(.init(title: "数量・保存方法を変更する", style: .default, handler: { [self] _ in
            let updationView = storyboard
            guard let updationView = updationView,
                  let modalImput = updationView.sheetPresentationController else { return }
            modalImput.detents = [.medium()]

            present(updationView, animated: true)
            // 共通部分をここに収める
            updationView.kindSelectText.isHidden = true
            updationView.unitSelectButton.isEnabled = false
            updationView.unitSelectButton.alpha = 1.0
            // 下記で消せるがボタンがViewの一番上まで来てしまうためConstraintを上書きする必要あり
            updationView.foodKindsStacks.isHidden = true
            updationView.parentStacKView.spacing = 50
            updationView.nameTextHeightconstraint.constant = 20
            updationView.quantityTextHeightConstraint.constant = 20

            // 以下直接FoodListPresenter.isTapRowだと不可
            if isTapRow {
                updationView.unitSelectButton
                    .setTitle(updationView.unitSelectButton
                        .unitButtonTranslator(unit: array[row].unit), for: .normal)
                updationView.foodNameTextField.text = array[row].name
                updationView.quantityTextField.text = array[row].quantity
                if !updationView.foodNameTextField.text!.isEmpty, !updationView.quantityTextField.text!.isEmpty {
                    updationView.preserveButton.isEnabled = true
                } else {
                    updationView.preserveButton.isEnabled = false
                }
                var locationString = ""
                updationView.refrigeratorButton.addAction(.init(handler: { _ in
                    // Model→Presenter→ここ
                    locationString = Food.Location.refrigerator.rawValue
                    self.foodListPresenter.setLocationOnUpdationView(row, locationString: locationString)
                }), for: .touchUpInside)
                updationView.freezerButton.addAction(.init(handler: { _ in
                    locationString = Food.Location.freezer.rawValue
                    self.foodListPresenter.setLocationOnUpdationView(row, locationString: locationString)
                }), for: .touchUpInside)
            }
            updationView.preserveButton.addAction(.init(handler: { [self] _ in

                if updationView.foodNameTextField.text!.isEmpty {
                    updationView.foodNameTextField.attributedPlaceholder =
                        NSAttributedString(string: "名称を入れてください",
                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                }
                if updationView.quantityTextField.text!.isEmpty {
                    updationView.quantityTextField.attributedPlaceholder =
                        NSAttributedString(string: "数量を入れてください",
                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                }
                if !updationView.foodNameTextField.text!.isEmpty, !updationView.quantityTextField.text!.isEmpty {
                    self.foodListPresenter.didTapPreserveOnUpdationView(
                        foodName: updationView.foodNameTextField.text,
                        foodQuantity: updationView.quantityTextField.text,
                        foodinArray: array[row]
                    )
                }
            }), for: .touchUpInside)
        }))
        // アラートアクションシート二項目目
        alert.addAction(.init(title: "レシピを調べる", style: .default, handler: { _ in
            // prepareと連動、RecipeCategoryViewへ移動
            self.performSegue(withIdentifier: "toRecipeTableView", sender: array[row].name)
        }))
        // アラートアクションシート三項目目
        alert.addAction(.init(title: "キャンセル", style: .destructive, handler: { _ in
        }))
        foodListPresenter.resetIsTapRow()
        present(alert, animated: true)
    }

    // AppendViewControllerへの遷移処理
    func perfomSeguetofoodAppendVC() { // (_ array:[Food],at:Int)
        performSegue(withIdentifier: "toFoodAppendVC", sender: nil)
    }

    // tableviewに説明文を表示
    func showRecoomendation() {
        recommendToAddLabel.text = "左上の＋から食品を登録できます"
        recommendToAddLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: foodListTableView.frame.width,
            height: 50
        )
        recommendToAddLabel.textAlignment = .center
        recommendToAddLabel.font = .systemFont(ofSize: 20)
        recommendToAddLabel.textColor = .gray
        recommendToAddLabel.backgroundColor = .clear
        foodListTableView.addSubview(recommendToAddLabel)
    }

    // recommendToAddLabelを削除
    func removeRecommendToAddLabel(_ isHidden: Bool) {
        recommendToAddLabel.isHidden = isHidden
    }

    // 削除するかどうかアラート
    func showDeleteAlert() {
        let alart = UIAlertController(title: "削除しますか?", message: "", preferredStyle: .actionSheet)
        alart.addAction(.init(title: "はい", style: .default, handler: { _ in
            self.foodListPresenter.deleteAction()
            self.reloadData()
        }))
        alart.addAction(.init(title: "いいえ", style: .destructive, handler: { _ in
            self.foodListPresenter.resetCheckedID()
            print("削除をキャンセル")
        }))
        present(alart, animated: true)
    }

    // firebaseの一回のID指定可能数が10個までのため制限
    func manageDeleteQuery() {
        // 削除可能数が10個までであることをアラート表示
        let limitTitile = "一度に10個まで削除可能です"
        let limitMessage = "現在\(foodListPresenter.checkedID.filter { $0.value == true }.count)個選択しています"
        let alart = UIAlertController(title: limitTitile, message: limitMessage, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {}
    }

    func setUpAdBanner() {
        // 実装テスト用ID
        bannerView.adUnitID = env["adUnitIDForList"]!
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.isHidden = false
    }

    func showIndicator() {
        indicatorBackView = UIView(frame: view.bounds)
        indicatorBackView.backgroundColor = .white
        indicatorBackView.alpha = 0.5
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(indicatorBackView)
        indicatorBackView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }
}
