//
//  RecepieViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieCategoryListViewController: UIViewController {
    @IBOutlet weak var recepieTable: UITableView!
    private let recepieCategoryListPresenter=RecepieCategoryListPresenter(recepieModel: RecepieModel())
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.recepieTable.delegate = self
        self.recepieTable.dataSource = self
        self.recepieCategoryListPresenter.setOutput(recepieCategoryListPresenterOutput: self)
        self.recepieCategoryListPresenter.reloadArray(searchKeyword: self.navigationItem.title)

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.recepieCategoryListPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recepieCell", for: indexPath) as? RecepieTableViewCell
        cell?.circlefill.text = "●"
        cell?.categoryName.text = self.recepieCategoryListPresenter.cellForRowAt(indexPath: indexPath)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recepieCategoryListPresenter.didSelectRow(indexPath: indexPath)
    }
}
extension RecepieCategoryListViewController: RecepieCategoryListPresenterOutput {
    func reloadData() {
        DispatchQueue.main.async {
            self.recepieTable.reloadData()
        }
    }
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    func setTitle() {
        if let title = self.navigationItem.title {
            self.navigationItem.title = ("\(title)のレシピ")
        }
    }
}
