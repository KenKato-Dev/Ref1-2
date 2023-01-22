//
//  UnitSelectButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class UnitSelectButton: UIButton {
    enum UnitMenu: String, Codable {
        case initial
        case gram
        case piece
        case bottle
        case bag
        case people
    }

    private(set) var selectedUnit = UnitMenu.initial

    func selectingUnit() {
        var unitActions = [UIMenuElement]()
        // グラム
        unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.gram),
                                    image: nil, state: selectedUnit == UnitMenu.gram ? .on : .off, handler: { _ in
                                        self.selectedUnit = .gram
                                        self.selectingUnit()
                                    }))
        // 個数
        unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.piece),
                                    image: nil, state: selectedUnit == UnitMenu.piece ? .on : .off, handler: { _ in
                                        self.selectedUnit = .piece
                                        self.selectingUnit()
                                    }))
        unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.bottle),
                                    image: nil, state: selectedUnit == UnitMenu.bottle ? .on : .off, handler: { _ in
                                        self.selectedUnit = .bottle
                                        self.selectingUnit()
                                    }))
        unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.bag),
                                    image: nil, state: selectedUnit == UnitMenu.bag ? .on : .off, handler: { _ in
                                        self.selectedUnit = .bag
                                        self.selectingUnit()
                                    }))
        unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.people),
                                    image: nil, state: selectedUnit == UnitMenu.people ? .on : .off, handler: { _ in
                                        self.selectedUnit = .people
                                        self.selectingUnit()
                                    }))
        menu = UIMenu(title: "", options: .displayInline, children: unitActions)
        showsMenuAsPrimaryAction = true
        setTitle(unitButtonTranslator(unit: selectedUnit), for: .normal)
    }

    func unitButtonTranslator(unit: UnitSelectButton.UnitMenu) -> String {
        var trasnlatedUnit = String()
        if unit == .gram {
            trasnlatedUnit = "グラム"
        } else if unit == .piece {
            trasnlatedUnit = "個"
        } else if unit == .bottle {
            trasnlatedUnit = "本"
        } else if unit == .bag {
            trasnlatedUnit = "袋"
        } else if unit == .people {
            trasnlatedUnit = "人数分"
        } else if unit == .initial {
            trasnlatedUnit = "単位を選んでください"
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
