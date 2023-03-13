//
//  FoodListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/10/10.
//

import Firebase
import Foundation

// ViewController側の処理を定義
protocol FoodListPresenterOutput: AnyObject {
    func reloadData()
    func presentErrorIfNeeded(_ errorOrNil: Error?)
    func dismiss()
    func setTitle(_ refigerator: Bool, _ freezer: Bool, _ selectedKinds: [Food.FoodKind], _ location: Food.Location)
    func arrangeDisplayingView(_ isDelete: Bool)
    func animateLocationButton(_ isFilteringRef: Bool, _ isFilteringFreezer: Bool)
    func resetButtonColor()
    func showAlertInCell(_ storyboard: FoodAppendViewController?, _ array: [Food], _ row: Int, _ isTapRow: Bool)
    func presentFoodAppendView()
    func presentAccountInforamtionView()
    func showRecoomendation()
    func removeRecommendToAddLabel(_ isHidden: Bool)
    func showDeleteAlert()
    func manageDeleteQuery()
    func setUpAdBanner()
    func showIndicator()
    func hideIndicator(_ isHidden: Bool)
}

// FoodListのPresenter
final class FoodListPresenter {
    private let foodData: FoodData
    private let foodUseCase: FoodUseCase
    private weak var foodListPresenterOutput: FoodListPresenterOutput?
    private(set) var array: [Food] = []
    private(set) var isDelete = true
    private(set) var checkedID: [String: Bool] = [:]
    private var didTapCheckBox: ((Bool) -> Void)?
    private(set) static var isTapRow = false
    private let db = Firestore.firestore()
    private var uid = Auth.auth().currentUser?.uid
    private(set) var titleText = ""
    init(foodData: FoodData, foodUseCase: FoodUseCase) {
        self.foodData = foodData
        self.foodUseCase = foodUseCase
    }

    // インスタンス変数の中身をViewController側から注入させる
    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }

    // Queryの生成、fetch、reloadDataを実行し配列表示を構築
    func fetchArray() {
        guard let uid = uid else { return }
        foodData.isConfiguringQuery(
            uid,
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds
        )
        foodData.fetch { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(foods):
                    self.array = foods
                    self.foodListPresenterOutput?.reloadData()
                    self.foodListPresenterOutput?.hideIndicator(true)
                    if self.array.isEmpty {
                        self.foodListPresenterOutput?.showRecoomendation()
                        // 追加
                        self.foodListPresenterOutput?.removeRecommendToAddLabel(false)
                    } else {
                        self.foodListPresenterOutput?.removeRecommendToAddLabel(true)
                    }
                case let .failure(error):
                    self.foodListPresenterOutput?.hideIndicator(true)
                    self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }
    }

    // ページネート処理、cell番号と配列数、querydoumentsnapshotの数で条件
    func didScrollToLast(row: Int) {
        if row == array.count - 1, foodData.countOfDocuments != 0 {
            foodData.paginate()
            foodData.fetch { result in
                switch result {
                case let .success(foods):
                    self.array.append(contentsOf: foods)
                    self.foodListPresenterOutput?.reloadData()
                case let .failure(error):
                    self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }
    }

    // 冷蔵ボタンの処理
    func didTapRefrigiratorButton(_: UIButton) {
        foodUseCase.didTapRefrigeratorButton()
        // ボタンの色を変更
        foodListPresenterOutput?.animateLocationButton(
            foodUseCase.isFilteringRefrigerator, foodUseCase.isFilteringFreezer
        )
        switchLocation(location: .refrigerator)
    }

    // 冷凍ボタンの処理
    func didTapFreezerButton(_: UIButton) {
        foodUseCase.didTapFreezerButton()
        foodListPresenterOutput?.animateLocationButton(
            foodUseCase.isFilteringRefrigerator, foodUseCase.isFilteringFreezer
        )
        switchLocation(location: .freezer)
    }

    // 冷蔵/冷凍ボタンの共通処理
    private func switchLocation(location: Food.Location) {
        foodUseCase.foodFilter.location = location
        foodUseCase.resetKinds(foodUseCase.isFilteringRefrigerator, foodUseCase.isFilteringFreezer)
        // タイトル編集
        foodListPresenterOutput?.setTitle(
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.selectedKinds,
            foodUseCase.foodFilter.location
        )
        fetchArray()
        print(foodData.query)
        foodListPresenterOutput?.reloadData()
    }

    // 食材ボタンの共通処理
    func didTapFoodKindButtons(_ kind: Food.FoodKind, _ button: UIButton) {
        foodUseCase.toggleDictionary(kind: kind)
        let selectedDictionary = foodUseCase.foodKindDictionary.filter { $0.value == true }
        var selectedFoodKinds = selectedDictionary.map(\.key)
        foodUseCase.foodFilter.kindArray = selectedFoodKinds
        // ここでselectedKindsに入る
        foodUseCase.isAddingKinds(selectedKinds: &selectedFoodKinds)
        fetchArray()

        // 押されたボタンのBool値Valueを基準にボタン外観を変更
        if foodUseCase.foodKindDictionary[kind]! {
            button.setImage(UIImage(named: kind.rawValue + "ButtonSelected"), for: .normal)
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            button.setImage(UIImage(named: kind.rawValue + "Button"), for: .normal)
            button.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        foodListPresenterOutput?.reloadData()
    }

    // Bool値を条件に配列フィルターと配列を初期化
    func refreshArrayIfNeeded(row: Int) -> Food? {
        if !foodUseCase.isFilteringFreezer,
           !foodUseCase.isFilteringRefrigerator,
           foodUseCase.selectedKinds.isEmpty {
            foodUseCase.resetDictionary()
            foodUseCase.foodFilter.kindArray = Food.FoodKind.allCases
            foodListPresenterOutput?.resetButtonColor()
        }
        return array[row]
    }

    // 削除ボタンの処理
    func didTapDeleteButton() {
        isDelete.toggle()
        // ボタンの無効化
        foodListPresenterOutput?.arrangeDisplayingView(isDelete)
        if isDelete, checkedID.values.contains(true) {
            if checkedID.filter { $0.value == true }.count > 10 {
                self.foodListPresenterOutput?.manageDeleteQuery()
                isDelete = false
                foodListPresenterOutput?.arrangeDisplayingView(isDelete)
            } else {
                foodListPresenterOutput?.showDeleteAlert()
            }
        }
        foodListPresenterOutput?.reloadData()
    }

    // クロージャ変数didTapに引数atを加えて返す、返り値をcell定義のクロージャに代入するための処理
    func setArgInDidTapCheckBox(at: Int) -> ((Bool) -> Void)? {
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[at].IDkey] = isChecked
        }
//        print(self.checkedID)
        return didTapCheckBox
    }

    // addButtonを押した時の処理
    func didTapAddButton() {
        foodListPresenterOutput?.presentFoodAppendView()
    }
    // AccountButtonの処理
    func didTapAccountButtton() {
        foodListPresenterOutput?.presentAccountInforamtionView()
    }
    // tableViewのcellの列数の処理
    func numberOfRows() -> Int {
        return array.count
    }

    // cell選択時の処理
    func didSelectRow(storyboard: FoodAppendViewController?, row: Int) {
        FoodListPresenter.isTapRow = true
        if isDelete {
            foodListPresenterOutput?.showAlertInCell(storyboard, array, row, FoodListPresenter.isTapRow)
        }
    }

    //
    func didTapPreserveOnUpdationView(foodName: String?, foodQuantity: String?, foodinArray: Food) {
        guard let uid = uid else { return }
        foodData.postFromUpdationView(
            uid, foodName: foodName,
            foodQuantity: foodQuantity,
            foodinArray: foodinArray
        ) { result in
            switch result {
            case .success:
                FoodListPresenter.isTapRow = false
            case let .failure(error):
                self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                FoodListPresenter.isTapRow = false
            }
        }
        foodData.isConfiguringQuery(
            uid,
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds
        )
        foodData.fetch { result in

            DispatchQueue.main.async {
                switch result {
                case let .success(foods):
                    self.array = foods
                    self.foodListPresenterOutput?.reloadData()
                case let .failure(error):
                    self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }
        foodListPresenterOutput?.dismiss()
    }

    func setLocationOnUpdationView(_ row: Int, locationString: String) {
        guard let uid = uid else { return }
        foodData.setLocation(uid, array[row].IDkey, locationString)
    }

    func deleteAction() {
        //                 filterで値のみを取り出し、defoはTrueを取り出す
        let filteredIDictionary = checkedID.filter(\.value).map(\.key)
        guard let uid = uid else { return }
        foodData.delete(uid, filteredIDictionary) { result in
            switch result {
            case .success:
                // ここから
                self.checkedID = [:]
                self.foodData.isConfiguringQuery(
                    uid,
                    self.foodUseCase.isFilteringRefrigerator,
                    self.foodUseCase.isFilteringFreezer,
                    self.foodUseCase.foodFilter,
                    self.foodUseCase.selectedKinds
                )
                self.foodData.fetch { result in
                    switch result {
                    case let .success(foods):
                        self.array = foods
                    case let .failure(error):
                        self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                        print("fetchfoodsに失敗:\(error)")
                    }
                    self.foodListPresenterOutput?.reloadData()
                }
            case let .failure(error):
                self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                print("deleteに失敗:\(error)")
            }
        }
    }

    func resetCheckedID() {
        checkedID = [:]
    }

    func resetIsTapRow() {
        FoodListPresenter.isTapRow = false
    }

    func displayTitle() {
        foodListPresenterOutput?.setTitle(
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.selectedKinds,
            foodUseCase.foodFilter.location
        )
    }

    func displayBanner() {
        foodListPresenterOutput?.setUpAdBanner()
    }

    // viewWill/DidAppearに入れると余分なViewが生成されるため単独でここから呼ぶ
    func displayIndicator() {
        foodListPresenterOutput?.showIndicator()
    }
}
