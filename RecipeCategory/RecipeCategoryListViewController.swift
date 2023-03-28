//
//  RecipeViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

// RecipeCategoryViewのVC
class RecipeCategoryListViewController: UIViewController {
    @IBOutlet var recipeTable: UITableView!
    private let activityIndicator = UIActivityIndicatorView()
    private var indicatorBackView = UIView()
    private let seatchResultLabel = UILabel()
    private let recipeCategoryListPresenter = RecipeCategoryListPresenter(recipeModel: RecipeModel())
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeTable.delegate = self
        recipeTable.dataSource = self
        recipeCategoryListPresenter.setOutput(recipeCategoryListPresenterOutput: self)
        recipeCategoryListPresenter.reloadArray(searchKeyword: navigationItem.title)
        recipeTable.register(UINib(nibName: "RecipeCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
    }
}

// tableViewの各処理をVCに準拠
extension RecipeCategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        recipeCategoryListPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as? RecipeCategoryCell
        cell?.categoryName.text = recipeCategoryListPresenter.cellForRowAt(indexPath: indexPath)
        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipeCategoryListPresenter.didSelectRow(indexPath: indexPath)
    }
}

extension RecipeCategoryListViewController: RecipeCategoryListPresenterOutput {
    func reloadData() {
        recipeTable.reloadData()
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    // FoodListVCよりprepareにて挿入、このタイトルでレシピ検索するためタイトルには食品名のみ入れる
    func setTitle() {
        if let title = navigationItem.title {
            navigationItem.title = "\(title)のレシピ集"
        }
    }

    // indicatorと背景をセットで表示
    func showIndicator() {
        indicatorBackView = UIView(frame: view.bounds)
        indicatorBackView.backgroundColor = .white
        indicatorBackView.alpha = 0.5

        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        indicatorBackView.addSubview(activityIndicator)
        view.addSubview(indicatorBackView)
        activityIndicator.startAnimating()
    }

    // indicatorと背景をセットで隠蔽
    func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }

    // 食品で楽天APIにリクエストした結果が0の際に表示
    func showNoResult() {
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        // 名前を試験表示
        seatchResultLabel.text = "\(navigationItem.title!)のレシピは見つかりませんでした"
        seatchResultLabel.frame = CGRect(
            x: 0, // self.foodListTableView.frame.width/2
            y: recipeTable.frame.height / 3,
            width: recipeTable.frame.width,
            height: 50
        )
        seatchResultLabel.textAlignment = .center
        seatchResultLabel.font = .systemFont(ofSize: 20)
        seatchResultLabel.textColor = UIColor.gray
        seatchResultLabel.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        seatchResultLabel.adjustsFontSizeToFitWidth = true
        // navigationItemでは表示されず
        recipeTable.addSubview(seatchResultLabel)
        seatchResultLabel.alpha = 1
    }

    // エラー内容を表示、将来的にStringsファイルにてエラー内容に応じて文章を変更予定
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = "エラー発生:\(error.localizedDescription)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {}
    }

    func showJumpMessageIfNeeded(indexPath: IndexPath) {
        let title = "外部リンクを開きますか？"
        let message = "楽天レシピにアクセスします"

        let alart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alart.addAction(.init(title: "はい", style: .default, handler: { _ in
            self.recipeCategoryListPresenter.openUrl(indexPath: indexPath)
        }))
        alart.addAction(.init(title: "いいえ", style: .destructive, handler: { _ in

        }))
        present(alart, animated: true) {}
    }
}
