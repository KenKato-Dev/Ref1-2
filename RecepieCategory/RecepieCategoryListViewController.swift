//
//  RecepieViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

// RecepieCategoryViewのVC
class RecepieCategoryListViewController: UIViewController {

    @IBOutlet var recepieTable: UITableView!
    private let activityIndicator = UIActivityIndicatorView()
    private var indicatorBackView = UIView()
    private let seatchResultLabel = UILabel()
    private let recepieCategoryListPresenter = RecepieCategoryListPresenter(recepieModel: RecepieModel())
    override func viewDidLoad() {
        super.viewDidLoad()
        recepieTable.delegate = self
        recepieTable.dataSource = self
        recepieCategoryListPresenter.setOutput(recepieCategoryListPresenterOutput: self)
        recepieCategoryListPresenter.reloadArray(searchKeyword: navigationItem.title)
    }
}
// tableViewの各処理をVCに準拠
extension RecepieCategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        recepieCategoryListPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recepieCell", for: indexPath) as? RecepieCategoryCell
        cell?.categoryName.text = recepieCategoryListPresenter.cellForRowAt(indexPath: indexPath)
        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        recepieCategoryListPresenter.didSelectRow(indexPath: indexPath)
    }
}
// presenter側で定義した中身に
extension RecepieCategoryListViewController: RecepieCategoryListPresenterOutput {
    func reloadData() {
//        DispatchQueue.main.async {
            self.recepieTable.reloadData()
//        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func setTitle() {
        if let title = navigationItem.title {
            navigationItem.title = "\(title)のレシピ集"
        }
    }
    func showLoadingSpin() {
        self.indicatorBackView = UIView(frame: self.view.bounds)
        self.indicatorBackView.backgroundColor = .white
        self.indicatorBackView.alpha = 0.5
        self.indicatorBackView.tag = 100100

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .large
        self.activityIndicator.color = .gray
        self.activityIndicator.center = self.view.center
        self.indicatorBackView.addSubview(activityIndicator)
        self.view.addSubview(indicatorBackView)
        self.activityIndicator.startAnimating()
    }
    func hideIndicator() {
        if let backView = self.view.viewWithTag(100100) {
            backView.removeFromSuperview()
        }
    }
    func showNoResult() {
            self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
            // 名前を試験表示
        self.seatchResultLabel.text = "\(navigationItem.title!)のレシピは見つかりませんでした"
        self.seatchResultLabel.frame = CGRect(
                x: 0, // self.foodListTableView.frame.width/2
                y: self.recepieTable.frame.height/3,
                width: self.recepieTable.frame.width,
                height: 50)
        self.seatchResultLabel.textAlignment = .center
        self.seatchResultLabel.font = .systemFont(ofSize: 20)
        self.seatchResultLabel.textColor = UIColor.gray
        self.seatchResultLabel.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        self.seatchResultLabel.adjustsFontSizeToFitWidth = true
            // navigationItemでは表示されず
        self.recepieTable.addSubview(self.seatchResultLabel)
        self.seatchResultLabel.alpha = 1
    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
}
