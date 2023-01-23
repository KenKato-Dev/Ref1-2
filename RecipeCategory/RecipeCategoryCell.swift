//
//  RecipeTableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/08/23.
//

import UIKit

class RecipeCategoryCell: UITableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var categoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        isSettingIconImage()
        isSettingCategoryName()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func isSettingIconImage() {
        let image = UIImage(named: "recipe")

        let imageSize = CGSize(width: 90, height: 90)
        let render = UIGraphicsImageRenderer(size: imageSize)
        let scaleImage = render.image { _ in
            image?.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        iconImage.image = scaleImage
        iconImage.contentMode = .scaleAspectFit
    }

    func isSettingCategoryName() {
        categoryName.adjustsFontSizeToFitWidth = true
        categoryName.textColor = .darkGray
    }
}
