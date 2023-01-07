//
//  AppDelegate.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
        FirebaseApp.configure()
            let window = UIWindow(frame: UIScreen.main.bounds)
                    self.window = window
                    // ここでアプリの初期画面を端末に反映させる
//                    Router.showRoot(window: window)

//            UserService().checkSignInStatus { isSignIn in
//                if isSignIn {
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let signInVC: SignInViewController = storyboard.instantiateViewController(withIdentifier: "signInVC") as! SignInViewController
//                    self.window?.rootViewController = signInVC
//                    self.window?.rootViewController!.performSegue(withIdentifier: "toFoodListView", sender: nil)
//                } else {
//                    print("サインイン履歴なし")
//                }
//            }

        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}
}
