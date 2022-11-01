//
//  checkBoxButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/13.
//

import UIKit

class CheckBoxButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        customDesign()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customDesign()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customDesign()
    }

    private func customDesign() {
        setImage(UIImage(systemName: "square")!, for: .normal)
        layer.masksToBounds = true
        layer.cornerRadius = 15.0
        backgroundColor = UIColor.clear
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    }

    func updateAppearance(isChecked: Bool) {
        // トグルの中でisCheckを入れ替えるようにしてImageを連携させる
        if isChecked {
            self.setImage(UIImage(systemName: "checkmark.square")!, for: .normal)
        } else {
            self.setImage(UIImage(systemName: "square")!, for: .normal)
        }
    }
}
