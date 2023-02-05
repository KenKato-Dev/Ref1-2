//
//  deleteButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/16.
//

import UIKit

class DeleteButton: UIButton {
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
        touchStartAnimation()
    }

    // タップキャンセル時の処理
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEndAnimation()
    }

    // タップ終了時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEndAnimation()
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
                         completion: nil)
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
                         completion: nil)
    }

    //
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customDesign()
    }

    private func customDesign() {
        setImage(UIImage(systemName: "trash")?.withTintColor(.red), for: .normal)
        // テキスト挿入
        setTitle("", for: .normal)
        // マスク適用
        layer.masksToBounds = true
        // 角丸み
        layer.cornerRadius = 10.0
        // 背景色
        backgroundColor = UIColor.clear
        // テキスト色
        setTitleColor(UIColor.red, for: .normal)
        // テキストサイズ
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        imageView?.image?.withTintColor(.red)
    }

    // bool=trueの際に作動
    func imageChange(bool: Bool) {
        if bool {
            setImage(UIImage(systemName: "trash"), for: .normal)
            setTitle("", for: .normal)

        } else {
            setImage(.remove, for: .normal)
            setTitle("", for: .normal)
            setTitleColor(.red, for: .normal)
        }
    }
}
