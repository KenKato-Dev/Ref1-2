//
//  TableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
class TableViewCell: UITableViewCell {
    // 下記enumを追加、normal. trueとfalseの3肢を用意
    // checkboxの出現、checkboxのsetImage切り替えをこれでまとめる
    enum State {
        case normal
        case shownCheckBox(isChecked: Bool)
    }

    @IBOutlet var checkBoxButton: CheckBoxButton!
    @IBOutlet var preserveMethodTextLable: UILabel!
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodNameTextLabel: UILabel!
    @IBOutlet var dateTextLabel: UILabel!
    @IBOutlet var quantityTextLabel: UILabel!
    @IBOutlet var unitTextLabel: UILabel!
    // インスタンスを追加
    private var state: State = .normal
    var didTapCheckBox: ((Bool) -> Void)?
    // awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addAction(.init(handler: { _ in

            if case let .shownCheckBox(isChecked) = self.state {
                let nextIsChecked = !isChecked
                self.didTapCheckBox?(nextIsChecked)
                self.configure(state: .shownCheckBox(isChecked: nextIsChecked))
            }
        }), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(state: .normal)
    }

    func foodConfigure(food: Food) {
        preserveMethodTextLable.text = locationTranslator(location: food.location)
        foodImage.image = UIImage(named: "\(food.kind.rawValue)") // ?.compositeText(preserveMethodTextLable.text as! NSString)
        foodNameTextLabel.text = food.name
        quantityTextLabel.text = String(food.quantity)
        unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: food.unit)
        dateTextLabel.text = food.date.formatted(date: .abbreviated, time: .omitted)
    }

    func configure(state: State) {
        self.state = state
        switch state {
        case .normal:
            checkBoxButton.isHidden = true
        case let .shownCheckBox(isChecked):
            checkBoxButton.isHidden = false
            checkBoxButton.updateAppearance(isChecked: isChecked)
        }
    }
//    func disableSelectCell(_ isDelete: Bool) {
//        self.foodImage.isUserInteractionEnabled = isDelete
//        self.foodNameTextLabel.isUserInteractionEnabled = isDelete
//        self.dateTextLabel.isUserInteractionEnabled = isDelete
//        self.quantityTextLabel.isUserInteractionEnabled = isDelete
//        self.unitTextLabel.isUserInteractionEnabled = isDelete
//    }
    private func locationTranslator(location: Food.Location) -> String {
        var trasnlatedlocation = String()
        if location == .refrigerator {
            trasnlatedlocation = "冷蔵"
        } else if location == .freezer {
            trasnlatedlocation = "冷凍"
        }
        return trasnlatedlocation
    }
}
