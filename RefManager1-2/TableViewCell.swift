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

// TODO: Rename
class TableViewCell: UITableViewCell {
    enum State {
        case normal
        case shownCheckBox(isChecked: Bool)
    }

    @IBOutlet weak var checkBoxButton: CheckBoxButton!
    @IBOutlet weak var preserveMethodTextLable: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodNameTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var quantityTextLabel: UILabel!
    @IBOutlet weak var unitTextLabel: UILabel!
    var didTapCheckBox: ((Bool) -> Void)?

    private var state: State = .normal

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addAction(.init(handler: { _ in
            if case .shownCheckBox(let isCheckd) = self.state {
                let nextIsCheckd = !isCheckd
                self.checkBoxButton.updateAppearance(isChecked: nextIsCheckd)
                self.didTapCheckBox?(nextIsCheckd)
                self.configure(state: .shownCheckBox(isChecked: nextIsCheckd))
            }
        }), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(state: .normal)
    }

    func foodConfigure(food: Food) {
        foodImage.image = UIImage(named: "\(food.kind.rawValue)") // foodArray[indexPath.row]
        preserveMethodTextLable.text = self.locationTranslator(location: food.location)
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
        case .shownCheckBox(isChecked: let isChecked):
            checkBoxButton.isHidden = false
            checkBoxButton.updateAppearance(isChecked: isChecked)
        }
    }

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
