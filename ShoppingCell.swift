//
//  ShoppingCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/30.
//

import UIKit

class ShoppingCell: UITableViewCell {
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func naming(_ nameText: String) {
        self.itemNameLabel.text = nameText
    }
    func checkCircle(_ isBuying: Bool) {
        if isBuying {
            circleImage.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            circleImage.image = UIImage(systemName: "circle")
        }
    }
}
