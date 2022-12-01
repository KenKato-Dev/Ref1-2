//
//  RecepieViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieCategoryListViewController: UIViewController {

    @IBOutlet var recepieTable: UITableView!
    private let recepieCategoryListPresenter = RecepieCategoryListPresenter(recepieModel: RecepieModel())
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        recepieTable.delegate = self
        recepieTable.dataSource = self
        recepieCategoryListPresenter.setOutput(recepieCategoryListPresenterOutput: self)
        recepieCategoryListPresenter.reloadArray(searchKeyword: navigationItem.title)
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension RecepieCategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        recepieCategoryListPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recepieCell", for: indexPath) as? RecepieTableViewCell
        cell?.categoryName.text = recepieCategoryListPresenter.cellForRowAt(indexPath: indexPath)
        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        recepieCategoryListPresenter.didSelectRow(indexPath: indexPath)
    }
}

extension RecepieCategoryListViewController: RecepieCategoryListPresenterOutput {
    func reloadData() {
        DispatchQueue.main.async {
            self.recepieTable.reloadData()
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func setTitle() {
        if let title = navigationItem.title {
            navigationItem.title = "\(title)のレシピ集"
        }
    }
    func presentErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else{return}
        let message = "エラー発生:\(error)"
        let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alart, animated: true) {
        }
    }
}
