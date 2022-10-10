//
//  RecepieViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var recepieTable: UITableView!
    private(set)var array: [MediumAndSmall]=[]
    var searchKeyword: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.recepieTable.delegate = self
        self.recepieTable.dataSource = self
        RecepieModel().fetchCategory(keyword: searchKeyword) { result in
            switch result {
            case .success(let categories):
                self.array = categories
                DispatchQueue.main.async {
                    self.recepieTable.reloadData()
                }
            case.failure(let error):
                print(error)
                self.dismiss(animated: true, completion: nil)
            }
        }
//        FoodData.shared.fetchRankingFromAPI { result in
//                switch result {
//                case .success(let recepies):
//                    self.array = recepies
//                    DispatchQueue.main.async {
//                        self.recepieTable.reloadData()
//                    }
//                case .failure(let error):
//                    print(error)
//                }
//        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recepieCell", for: indexPath) as? RecepieTableViewCell
        cell?.circlefill.text = "●"
        cell?.categoryName.text = array[indexPath.row].categoryName
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIApplication.shared.canOpenURL(URL(string: (array[indexPath.row].categoryUrl))!) {
            UIApplication.shared.open(URL(string: (array[indexPath.row].categoryUrl))!)
        } else {
            print("URLとして開けません:\(URL(string: (array[indexPath.row].categoryUrl))!)")
        }
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
