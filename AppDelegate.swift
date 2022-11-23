//
//  AppDelegate.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        FoodData().isConfiguringQuery(
//            true,
//            false,
//            FoodData.Filter(location: .refrigerator, kindArray: [.meat, .fish])
//        )
//        FoodData().fetch { result in
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                switch result {
//                case let .success(foods):
//                    print("完了：\(foods)")
//                    //                self.array.sorted(by: { $0.kind.rawValue > $1.kind.rawValue })
//                case let .failure(error):
//                    print(error)
//                }
//            }
//        }

        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
