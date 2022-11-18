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
//        FoodData.shared.delete(idKeys: ["1C7F7790-54BA-4498-8861-2EF7F037D13D", "3E28A2AE-9282-4A64-A513-7B5037F8ACE6", "633D8AEF-B7B3-448D-A9CB-158FE30936CA"])
//        FoodData.shared.fetchFoods { result in
//            switch result {
//            case .success(let foods):
//                print(foods)
//            case .failure(let error):
//                print(error)
//            }
//        }
//        FoodData.shared.fetchListCount { count in
//            print("リストの数：\(count)")
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
