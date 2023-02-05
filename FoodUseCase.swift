//
//  FoodUseCase.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/05/18.
//

import Foundation
import UIKit

// ボタン操作時の処理のうちBool値の変化やEnumの追加削除等フィルター機能を担当
final class FoodUseCase {
    private(set) var isFilteringRefrigerator = false
    private(set) var isFilteringFreezer = false
    private(set) var selectedKinds: [Food.FoodKind] = []
    var foodFilter = FoodData.Filter(location: .refrigerator, kindArray: Food.FoodKind.allCases)
    private(set) var foodKindDictionary: [Food.FoodKind: Bool] = [
        .meat: false, .fish: false, .vegetableAndFruit: false,
        .milkAndEgg: false, .dish: false, .drink: false,
        .seasoning: false, .sweet: false, .other: false,
    ]
    // 冷蔵ボタン操作の際のBool値操作
    func didTapRefrigeratorButton() {
        isFilteringRefrigerator.toggle()
        isFilteringFreezer = false
    }

    // 冷凍ボタン操作の際のBool値操作
    func didTapFreezerButton() {
        isFilteringFreezer.toggle()
        isFilteringRefrigerator = false
    }

    // 種類ボタン操作時に押されたボタンのEnum値を変数selectedKindsに代入
    func isAddingKinds(selectedKinds: inout [Food.FoodKind]) {
        self.selectedKinds = selectedKinds
    }

    // Bool値を条件に変数selectedKindsを空にする処理
    func resetKinds(_ refrigator: Bool, _ freezer: Bool) {
        if !refrigator, !freezer {
            selectedKinds = []
        }
    }

    // 種類ボタンを押した際ディクショナリfoodKindDictionaryのボタンと連動するEnum値KeyのBool値のValueをtoggle
    func toggleDictionary(kind: Food.FoodKind) {
        foodKindDictionary[kind]!.toggle()
    }

    // ディクショナリfoodKindDictionaryを初期値に戻す
    func resetDictionary() {
        foodKindDictionary = [
            .meat: false, .fish: false, .vegetableAndFruit: false,
            .milkAndEgg: false, .dish: false, .drink: false,
            .seasoning: false, .sweet: false, .other: false,
        ]
    }
}
