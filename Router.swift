//
//  Router.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/01/07.
//

import Foundation
import UIKit

final class Router {
    // アプリの初期画面を表示するメソッド
    static func showRoot(window: UIWindow) {
        // ユーザーのログイン状態を取得する
        UserService.shared.checkSignInStatus { isSignIn in
            let rootVC = SignInViewController.checkSignInStatus(isSignIn)
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
        }
    }
}
