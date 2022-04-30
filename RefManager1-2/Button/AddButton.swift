//
//  AddButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/16.
//

import UIKit

class AddButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        customDesign()
      }
      required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
          // 下記がない場合Viewが初めて表示された際にStoryboard上で決めた初期値になる
        customDesign()
      }
      override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customDesign()
      }
    private func customDesign() {
        setImage(UIImage(systemName: "plus"), for: .normal)
        // テキスト挿入
        setTitle("", for: .normal)
        // マスク適用
        layer.masksToBounds = true
        // 角丸み
//        layer.cornerRadius = 15.0
        // 枠線の色
//        layer.borderColor = UIColor(displayP3Red: 79/255, green: 172/255, blue: 254/255,alpha: 1.0).cgColor
        // 枠線の太さ
//        layer.borderWidth = 2
        // Padding
//        contentEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        // 背景色
        backgroundColor = UIColor.white
        // テキスト色
        setTitleColor(UIColor.red, for: .normal)
//        setTitleColor(UIColor(displayP3Red: 79/255, green: 172/255, blue: 254/255,alpha: 1.0), for: .normal)
        // テキストサイズ
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        imageView?.image?.withTintColor(.red)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
