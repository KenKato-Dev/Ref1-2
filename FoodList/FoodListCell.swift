//
//  TableViewCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit
class FoodListCell: UITableViewCell {
    // normal. trueとfalseの3択によりcheckboxの出現、checkboxのsetImage切り替えを本Enumにまとめる
    enum State {
        case normal
        case shownCheckBox(isChecked: Bool)
    }

    @IBOutlet var checkBoxButton: CheckBoxButton!
    @IBOutlet var preserveMethodTextLabel: UILabel!
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
            // isCheckにはVCにてcheckdIDの戻り値Valueが代入
            if case let .shownCheckBox(isChecked) = self.state {
                let nextIsChecked = !isChecked
                // didTapにはPresenterで用意した同じクロージャ型をVC上で代入
                self.didTapCheckBox?(nextIsChecked)
                self.controllCheckBox(state: .shownCheckBox(isChecked: nextIsChecked))
            }
        }), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        controllCheckBox(state: .normal)
    }

    func composeFood(food: Food) {
        preserveMethodTextLabel.text = locationTranslator(location: food.location)
        preserveMethodTextLabel.layer.cornerRadius = 15
        preserveMethodTextLabel.clipsToBounds = true
        foodNameTextLabel.adjustsFontSizeToFitWidth = true
        // 冷蔵冷凍タグマークを構成
        if preserveMethodTextLabel.text == "冷蔵" {
            preserveMethodTextLabel.textColor = .white
            preserveMethodTextLabel.backgroundColor = UIColor(named: "ref")
            preserveMethodTextLabel.layer.borderColor = UIColor(.clear).cgColor
            preserveMethodTextLabel.layer.borderWidth = 2

        } else if preserveMethodTextLabel.text == "冷凍" {
            preserveMethodTextLabel.textColor = UIColor(named: "freezer")
            preserveMethodTextLabel.backgroundColor = .white
            preserveMethodTextLabel.layer.borderColor = UIColor(named: "freezer")?.cgColor
            preserveMethodTextLabel.layer.borderWidth = 2
        }
        //
        foodImage.image = UIImage(named: "\(food.kind.rawValue)")
        foodNameTextLabel.text = food.name
        quantityTextLabel.text = String(food.quantity)
        unitTextLabel.text = UnitSelectButton().unitButtonTranslator(unit: food.unit)
        dateTextLabel.text = food.date.formatted(date: .abbreviated, time: .omitted)
    }

    func controllCheckBox(state: State) {
        self.state = state
        switch state {
        case .normal:
            checkBoxButton.isHidden = true
        case let .shownCheckBox(isChecked):
            checkBoxButton.isHidden = false
            checkBoxButton.updateAppearance(isChecked: isChecked)
            selectionStyle = .none
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
