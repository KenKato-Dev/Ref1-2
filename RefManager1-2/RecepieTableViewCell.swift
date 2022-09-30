//
//  RecepieTableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieTableViewCell: UITableViewCell {
    @IBOutlet weak var recepieImageView: UIImageView!
    @IBOutlet weak var recepieTitleLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var numberOfFaboriteLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getImage(url: String) -> UIImage {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch {
            print(error)
        }
        return UIImage()
    }

}
