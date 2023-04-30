//
//  Food.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/09.
//

import Foundation
// Firebaseからデコード時に取り出せる形に調整
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// カスタム構造、Firebase上の情報をこの構造にデコード
struct Food: Equatable, Codable {
    var location: Location
    var kind: FoodKind
    var name: String
    var quantity: String
    var unit: UnitSelectButton.UnitMenu
    var IDkey: String
    var date: Date

    enum Location: String, CaseIterable, Codable {
        case refrigerator
        case freezer
    }

    // 食材の種類に対応するEnum、Query作成用に変数kindNumberを持つ
    enum FoodKind: String, CaseIterable, Codable {
        case meat
        case fish
        case vegetableAndFruit
        case milkAndEgg
        case dish
        case drink
        case seasoning
        case sweet
        case other

        var kindNumber: String {
            switch self {
            case .meat:
                return "1"
            case .fish:
                return "2"
            case .vegetableAndFruit:
                return "3"
            case .milkAndEgg:
                return "4"
            case .dish:
                return "5"
            case .drink:
                return "6"
            case .seasoning:
                return "7"
            case .sweet:
                return "8"
            case .other:
                return "9"
            }
        }
    }
}
