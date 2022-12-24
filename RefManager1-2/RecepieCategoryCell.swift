//
//  RecepieTableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecepieCategoryCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet var categoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSettingIconImage()
        self.isSettingCategoryName()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func isSettingIconImage() {
        let image = UIImage(systemName: "fork.knife.circle")?.withTintColor(.systemOrange)
        let imageSize = CGSize(width: 90, height: 90)
        let render = UIGraphicsImageRenderer(size: imageSize)
        let scaleImage = render.image { _ in
            image?.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        self.iconImage.image = scaleImage
        self.iconImage.contentMode = .scaleAspectFit
    }
    func isSettingCategoryName() {
        self.categoryName.adjustsFontSizeToFitWidth = true
        self.categoryName.textColor = .darkGray
    }
}
