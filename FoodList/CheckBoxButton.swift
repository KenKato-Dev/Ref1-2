//
//  checkBoxButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/13.
//

import UIKit

class CheckBoxButton: TapFeedbackView {
    // ボタンの内容
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
        // イメージ挿入
        setImage(UIImage(systemName: "square")!, for: .normal)
        //        setImage(checkedBox, for: .highlighted)
        // マスク適用
        layer.masksToBounds = true
        // 角丸み
        layer.cornerRadius = 15.0
        // 背景色
        backgroundColor = UIColor.clear
        // テキストサイズ
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    }

    // Bool引数isCheckによってボタン外観をsetImageを切り替えさせる
    func updateAppearance(isChecked: Bool) {
        if isChecked {
            setImage(UIImage(systemName: "checkmark.square")!, for: .normal)
//            print("押されました")
        } else {
            setImage(UIImage(systemName: "square")!, for: .normal)
        }
    }
}
