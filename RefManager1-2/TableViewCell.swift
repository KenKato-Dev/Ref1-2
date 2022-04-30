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
            checkBoxButton.isHidden = !showCheckBox
        }
    }
    var didTapCheckBox: ((Bool) -> Void)?
    private var isTap = false
    // awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxButton.addAction(.init(handler: { _ in
            self.isTap.toggle()
            self.checkBoxButton.updateAppearance(isChecked: self.isTap)
            self.didTapCheckBox?(self.isTap)
        }), for: .touchUpInside)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
