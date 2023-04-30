//
//  KindSelectButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/16.
//

import Foundation
import UIKit
class KindSelectButton: UIButton {

    private(set) var selectedKind = Food.FoodKind.meat
//    convenience init(){
//        self.init(frame: .zero)
//        var config = UIButton.Configuration.plain()
//        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom:10, trailing: 10)
//        self.configuration = config
//    }
    func selectingKind() {
        var unitActions = [UIMenuElement]()
//        self.configuration = .filled()
//        self.configuration?.imagePadding = 10
        self.contentVerticalAlignment = .bottom
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.lineBreakMode = .byClipping
//        self.titleLabel?.adjustsFontSizeToFitWidth = true
       //
        var config = UIButton.Configuration.borderless()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        self.configuration = config
        // グラム
        unitActions.append(UIAction(title: translateKindMenu(kind: .meat),
                                    image: UIImage(named: Food.FoodKind.meat.rawValue),
                                    state: selectedKind == .meat ? .on : .off, handler: { _ in
            self.selectedKind = .meat
            self.selectingKind()
        }))
        // 個数
        unitActions.append(UIAction(title: translateKindMenu(kind: .fish),
                                    image: UIImage(named: Food.FoodKind.fish.rawValue),
                                    state: selectedKind == .fish ? .on : .off, handler: { _ in
            self.selectedKind = .fish
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .vegetableAndFruit),
                                    image: UIImage(named: Food.FoodKind.vegetableAndFruit.rawValue),
                                    state: selectedKind == .vegetableAndFruit ? .on : .off, handler: { _ in
            self.selectedKind = .vegetableAndFruit
            self.selectingKind()

        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .milkAndEgg),
                                    image: UIImage(named: Food.FoodKind.milkAndEgg.rawValue),
                                    state: selectedKind == .milkAndEgg ? .on : .off, handler: { _ in
            self.selectedKind = .milkAndEgg
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .dish),
                                    image: UIImage(named: Food.FoodKind.dish.rawValue),
                                    state: selectedKind == .dish ? .on : .off, handler: { _ in
            self.selectedKind = .dish
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .drink),
                                    image: UIImage(named: Food.FoodKind.drink.rawValue),
                                    state: selectedKind == .drink ? .on : .off, handler: { _ in
            self.selectedKind = .drink
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .seasoning),
                                    image: UIImage(named: Food.FoodKind.seasoning.rawValue),
                                    state: selectedKind == .seasoning ? .on : .off, handler: { _ in
            self.selectedKind = .seasoning
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .sweet),
                                    image: UIImage(named: Food.FoodKind.sweet.rawValue),
                                    state: selectedKind == .sweet ? .on : .off, handler: { _ in
            self.selectedKind = .sweet
            self.selectingKind()
        }))
        unitActions.append(UIAction(title: translateKindMenu(kind: .other),
                                    image: UIImage(named: Food.FoodKind.other.rawValue),
                                    state: selectedKind == .other ? .on : .off, handler: { _ in
            self.selectedKind = .other
            self.selectingKind()
        }))
        menu = UIMenu(title: "", options: .displayInline, children: unitActions)
        showsMenuAsPrimaryAction = true
        setTitle(translateKindMenu(kind: selectedKind), for: .normal)
        self.configuration?.background.image = UIImage(named: selectedKind.rawValue)
        self.configuration?.attributedTitle?.font = UIFont.systemFont(ofSize: 5, weight: .light, width: .standard)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.setBackgroundImage(UIImage(named: selectedKind.rawValue),
//                                for: .normal)
        // style defaultのボタン用

    }

    func translateKindMenu(kind: Food.FoodKind) -> String {
        var trasnlatedUnit = String()
        if kind == .meat {
            trasnlatedUnit = "肉"
        } else if kind == .fish {
            trasnlatedUnit = "魚介"
        } else if kind == .vegetableAndFruit {
            trasnlatedUnit = "野菜・果物"
        } else if kind == .milkAndEgg {
            trasnlatedUnit = "乳・卵"
        } else if kind == .dish {
            trasnlatedUnit = "惣菜"
        } else if kind == .drink {
            trasnlatedUnit = "飲料"
        } else if kind == .seasoning {
            trasnlatedUnit = "調味料"
        } else if kind == .sweet {
            trasnlatedUnit = "スイーツ"
        } else if kind == .other {
            trasnlatedUnit = "その他のもの"
        }
        return trasnlatedUnit
    }

    func isEnablingPreserveButton(foodNameTextField: Bool, quantityTextField: Bool, preserveButton: UIButton) {
        if !foodNameTextField, !quantityTextField {
            preserveButton.isEnabled = true
        } else {
            preserveButton.isEnabled = false
        }
    }
}
