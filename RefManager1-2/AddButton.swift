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
    // ボタンのアニメーション
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touchStartAnimation()
    }

    // タップキャンセル時の処理
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchEndAnimation()
    }

    // タップ終了時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touchEndAnimation()
    }

    // ビューを凹んだように見せるアニメーション
    private func touchStartAnimation() {
        UIButton.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        // 少しだけビューを小さく縮めて、奥に行ったような「凹み」を演出する
                        self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                       completion: nil
        )
    }

    // 凹みを元に戻すアニメーション
    private func touchEndAnimation() {
        UIButton.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        // 元の倍率に戻す
                        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        },
                       completion: nil
        )
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
