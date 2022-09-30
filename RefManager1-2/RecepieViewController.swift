//
//  RecepieViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var recepieTable: UITableView!
    private(set)var array: [Recepie]=[]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.recepieTable.delegate = self
        self.recepieTable.dataSource = self
        FoodData.shared.fetchRankingFromAPI { result in
                switch result {
                case .success(let recepies):
                    self.array = recepies
                    DispatchQueue.main.async {
                        self.recepieTable.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recepieCell", for: indexPath) as? RecepieTableViewCell
        cell?.recepieImageView.image = cell?.getImage(url: self.array[indexPath.row].smallImageUrl)
        cell?.cookingTimeLabel.text = self.array[indexPath.row].recipeIndication
        cell?.numberOfFaboriteLabel.text = ("☆×\(self.array[indexPath.row].rank)")
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIApplication.shared.canOpenURL(URL(string: (array[indexPath.row].recipeUrl))!) {
            UIApplication.shared.open(URL(string: (array[indexPath.row].recipeUrl))!)
        } else {
            print("URLとして開けません:\(URL(string: (array[indexPath.row].recipeUrl))!)")
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
