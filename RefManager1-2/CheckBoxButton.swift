//
//  checkBoxButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/13.
//

import UIKit

class CheckBoxButton: TapFeedbackView {
    //    var isTap = false

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
        // 枠線の色
        //        layer.borderColor = UIColor(displayP3Red: 79/255, green: 172/255, blue: 254/255,alpha: 1.0).cgColor
        // 枠線の太さ
        //        layer.borderWidth = 2
        // Padding
        //        contentEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        // 背景色
        backgroundColor = UIColor.clear
        // テキスト色
        //        setTitleColor(UIColor.red, for: .normal)
        //        setTitleColor(UIColor(displayP3Red: 79/255, green: 172/255, blue: 254/255,alpha: 1.0), for: .normal)
        // テキストサイズ
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        //        imageView?.image?.withTintColor(.red)
    }
    // Bool引数isCheckによってボタン外観をsetImageを切り替えさせる
    func updateAppearance(isChecked: Bool) {
        if isChecked {
            self.setImage(UIImage(systemName: "checkmark.square")!, for: .normal)
        } else {
            self.setImage(UIImage(systemName: "square")!, for: .normal)
        }
    }
}
