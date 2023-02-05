//
//  UIImage+Extension.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/02.
//

import Foundation
import UIKit
extension UIImage {
    // 画像同士を重ねて新たな画像を生成する処理

    func compositeImage(_ originalImage: UIImage,
                        _ currentImage: UIImage,
                        _ image: UIImage,
                        _ value: CGFloat) -> UIImage
    {
        print("オリジン:\(originalImage),今:\(currentImage)")
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let rect = CGRect(x: (size.width - image.size.width) / 2,
                          y: (size.height - image.size.height) / 2,
                          width: image.size.width,
                          height: image.size.height)
        image.draw(in: rect, blendMode: .normal, alpha: value)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return image
    }

    // 画像とラベルを重ねて新たな画像を生成する処理
    func compositeText(_ text: NSString) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let textRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 200),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle: textStyle,
        ]
        text.draw(in: textRect, withAttributes: textFontAttributes as [NSAttributedString.Key: Any])
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return newImage
    }

    func showErrorIfNeeded(_ alart: inout UIAlertController, _ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = "エラー発生:\(error)"
        alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}
