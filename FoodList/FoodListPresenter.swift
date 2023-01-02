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
    func perfomSeguetofoodAppendVC()
    func fadeout()
    func showRecoomendation()
    func removeRecommendationLabel()
    func shouldShowUserName(_ userName: String)
    func showDeleteAlert()
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
    private (set) var titleText = ""
    init(foodData: FoodData, foodUseCase: FoodUseCase) {
        self.foodData = foodData
        self.foodUseCase = foodUseCase
    }
    // インスタンス変数の中身をViewController側から注入させる
    func setOutput(foodListPresenterOutput: FoodListPresenterOutput) {
        self.foodListPresenterOutput = foodListPresenterOutput
    }
//    func receiveUID(_ receivedUID: String) {
//        self.uid = receivedUID
//    }
    // Queryの生成、fetch、reloadDataを実行し配列表示を構築
    func fetchArray() {
        guard let uid = self.uid else {return}
        self.foodData.isConfiguringQuery(
            uid,
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds)
        self.foodData.fetch { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(foods):
                    self.array = foods
                    self.foodListPresenterOutput?.reloadData()
                    if self.array.isEmpty {
                        self.foodListPresenterOutput?.showRecoomendation()
                    } else {
                        self.foodListPresenterOutput?.removeRecommendationLabel()
                    }
                case let .failure(error):
                    self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                }
            }
        }
    }

    // ページネート処理、cell番号と配列数、querydoumentsnapshotの数で条件
    func didScrollToLast(row: Int) {
        if row == self.array.count - 1 && foodData.countOfDocuments != 0 {
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
        self.fetchArray()
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
        self.fetchArray()
        print(foodData.query)
        // 押したボタン画像を変更
        var image = UIImage(named: kind.rawValue + "Button")
        if button.imageView!.image == UIImage(named: kind.rawValue + "Button") {
            image = button.imageView!.image!.compositeImage(
                UIImage(named: kind.rawValue + "Button")!,
                button.imageView!.image!,
                UIImage(named: "selectedButton")!,
                0.5)
        }
        // 押されたボタンのBool値Valueを基準にボタン外観を変更
        if foodUseCase.foodKindDictionary[kind]! {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            button.isHighlighted = true
            button.setImage(image, for: .normal)
        } else {
            button.transform = CGAffineTransform(scaleX: 1, y: 1)
            button.isHighlighted = false
            button.setImage(UIImage(named: kind.rawValue + "Button"), for: .normal)
        }
        foodListPresenterOutput?.reloadData()
    }
    // Bool値を条件に配列フィルターと配列を初期化
    func refreshArrayIfNeeded(row: Int) -> Food? {
        if !foodUseCase.isFilteringFreezer &&
            !foodUseCase.isFilteringRefrigerator &&
            foodUseCase.selectedKinds.isEmpty {
            foodUseCase.resetDictionary()
            foodUseCase.foodFilter.kindArray = Food.FoodKind.allCases
            self.foodListPresenterOutput?.resetButtonColor()
        }
        return array[row]
    }
    // 削除ボタンの処理
    func didTapDeleteButton() {
        isDelete.toggle()
        // ボタンの無効化
        foodListPresenterOutput?.arrangeDisplayingView(isDelete)
        if isDelete, checkedID.values.contains(true) {
            self.foodListPresenterOutput?.showDeleteAlert()
        }
        foodListPresenterOutput?.reloadData()
    }
    // クロージャ変数didTapに引数atを加えて返す、返り値をcell定義のクロージャに代入するための処理
    func setArgInDidTapCheckBox(at: Int) -> ((Bool) -> Void)? {
        didTapCheckBox = { isChecked in
            self.checkedID[self.array[at].IDkey] = isChecked
        }
        return didTapCheckBox
    }
    // addButtonを押した時の処理
    func didTapAddButton() {
        self.foodListPresenterOutput?.perfomSeguetofoodAppendVC()
    }
    // tableViewのcellの列数の処理
    func numberOfRows() -> Int {
        return self.array.count

    }
    // cell選択時の処理
    func didSelectRow(storyboard: FoodAppendViewController?, row: Int) {
        FoodListPresenter.isTapRow = true
        if self.isDelete {
            self.foodListPresenterOutput?.showAlertInCell(storyboard, self.array, row, FoodListPresenter.isTapRow)
        }
    }
    //
     func didTapPreserveOnUpdationView(foodName: String?, foodQuantity: String?, foodinArray: Food) {
         guard let uid = self.uid else {return}
         self.foodData.postFromUpdationView(
            uid, foodName: foodName,
            foodQuantity: foodQuantity,
            foodinArray: foodinArray) { result in
            switch result {
            case .success:
                FoodListPresenter.isTapRow = false
            case let .failure(error):
                self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                FoodListPresenter.isTapRow = false
            }
        }
        self.foodData.isConfiguringQuery(
            uid,
            foodUseCase.isFilteringRefrigerator,
            foodUseCase.isFilteringFreezer,
            foodUseCase.foodFilter,
            foodUseCase.selectedKinds)
         self.foodData.fetch { result in

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
            self.foodListPresenterOutput?.dismiss()
    }
    func setLocationOnUpdationView(_ row: Int, locationString: String) {
        guard let uid = self.uid else {return}
        self.foodData.setLocation(uid, self.array[row].IDkey, locationString)
    }
    func deleteAction() {
        //                 filterで値のみを取り出し、defoはTrueを取り出す
        let filteredIDictionary = self.checkedID.filter(\.value).map(\.key)
        guard let uid = self.uid else {return}
        self.foodData.delete(uid, filteredIDictionary) { result in
            switch result {
            case .success:
                // ここから
                self.checkedID = [:]
                self.foodData.isConfiguringQuery(
                    uid,
                    self.foodUseCase.isFilteringRefrigerator,
                    self.foodUseCase.isFilteringFreezer,
                    self.foodUseCase.foodFilter,
                    self.foodUseCase.selectedKinds)
                self.foodData.fetch { result in
                    switch result {
                    case let .success(foods):
                        self.array = foods
                        self.array = self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
                        // このReloadにより削除がtableに反映
//                                self.foodListPresenterOutput?.reloadData()
                    case let .failure(error):
                        self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                        print("fetchfoodsに失敗:\(error)")
                    }
                    // 下記reloadがないと表示が反映されず1
                    self.foodListPresenterOutput?.reloadData()
                }
            case let .failure(error):
                self.foodListPresenterOutput?.presentErrorIfNeeded(error)
                print("deleteに失敗:\(error)")
            }
        }
    }
    func resetCheckedID() {
        self.checkedID = [:]
    }
    func resetIsTapRow() {
        FoodListPresenter.isTapRow = false
    }

    func greentingToUser() {
        self.foodData.fetchUserInfo { result in
                switch result {
                case let .success(user):
                    self.foodListPresenterOutput?.shouldShowUserName(user.userName)
                    self.foodListPresenterOutput?.fadeout()
                case .failure:
                    self.foodListPresenterOutput?.shouldShowUserName("情報取得を失敗しました")
                }
        }
    }
}
