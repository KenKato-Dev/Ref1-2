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
//    var showCheckBox: Bool = false {
//        didSet {
//            // Boolの関係性を理解し
//            checkBoxButton.isHidden = showCheckBox
//        }
//    }

    var didTapCheckBox: ((Bool) -> Void)?
    // awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addAction(.init(handler: { _ in
            //            self.checkBoxButton.isTap.toggle()
            //            self.checkBoxButton.updateAppearance(isChecked: self.checkBoxButton.isTap)
            //            self.didTapCheckBox?(self.checkBoxButton.isTap)
            if case let .shownCheckBox(isChecked) = self.state {
                let nextIsChecked = !isChecked
                // 下記記載はconfigureと重複するため不要
//                self.checkBoxButton.updateAppearance(isChecked: nextIsChecked)
                self.didTapCheckBox?(nextIsChecked)
                self.configure(state: .shownCheckBox(isChecked: nextIsChecked))
            }
        }), for: .touchUpInside)
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(state: .normal)
    }

    func foodConfigure(food: Food) {
        foodImage.image = UIImage(named: "\(food.kind.rawValue)") // foodArray[indexPath.row]
        preserveMethodTextLable.text = locationTranslator(location: food.location)
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
