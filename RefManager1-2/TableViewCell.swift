//
//  TableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
// エラー発生Thread 1: "[<UITableViewCell 0x13b642400> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key checkBoxButton."
// サブクラスを入れていないからかと緊急的にcheckBoxButtonを入れたがうまくいかず
// ターゲットからモジュールを先導を選択しエラー解決、Inherit module from targetカスタムクラス作成時に使用する
class TableViewCell: UITableViewCell {
    @IBOutlet weak var checkBoxButton: CheckBoxButton!
    @IBOutlet weak var preserveMethodTextLable: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodNameTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var quantityTextLabel: UILabel!
    @IBOutlet weak var unitTextLabel: UILabel!
    var showCheckBox: Bool = false {
        didSet {
            // Boolの関係性を理解し
            checkBoxButton.isHidden = showCheckBox
        }
    }
    var didTapCheckBox: ((Bool) -> Void)?
    // 下記のisTapはやはりCheckboxにあるべきという感覚を身につける
    // awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addAction(.init(handler: { _ in
            // toggleが動作せず、改善策がわかるまでコメントアウト、TableViewCell内のCheckBoxButtonにアクセスできず
//            var isTapInCheckBoxButton: Bool = CheckBoxButton.shared.returnIsTap()
//            CheckBoxButton.isTap.toggle()
            self.checkBoxButton.isTap.toggle()
            self.checkBoxButton.updateAppearance(isChecked: self.checkBoxButton.isTap)
            self.didTapCheckBox?(self.checkBoxButton.isTap)
        }), for: .touchUpInside)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func foodConfigure(food: Food) {
            foodImage.image = UIImage(named: "\(food.kind.rawValue)") // foodArray[indexPath.row]
            preserveMethodTextLable.text = self.locationTranslator(location: food.location)
            foodNameTextLabel.text = food.name
            quantityTextLabel.text = String(food.quantity)
            unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: food.unit)
            dateTextLabel.text = food.date.formatted(date: .abbreviated, time: .omitted)

    }
    func filteredConfigure(filteredFood: Food) {
        foodImage.image = UIImage(named: "\(filteredFood.kind.rawValue)")
        preserveMethodTextLable.text = self.locationTranslator(location: filteredFood.location)
        foodNameTextLabel.text = filteredFood.name
        quantityTextLabel.text = String(filteredFood.quantity)
        unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: filteredFood.unit)
        dateTextLabel.text = filteredFood.date.formatted(date: .abbreviated, time: .omitted)
    }
    func locationTranslator(location: Food.Location) -> String {
        var trasnlatedlocation = String()
        if location == .refrigerator {
            trasnlatedlocation = "冷蔵"
        } else if location == .freezer {
            trasnlatedlocation = "冷凍"
        }
        return trasnlatedlocation
    }
}
