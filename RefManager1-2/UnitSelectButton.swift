//
//  UnitSelectButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//
// 参考１：https://qiita.com/takashico/items/3a94831801869f4203f2
// 2：https://note.com/creative_life/n/n2f4eb376c568

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

    var selectedUnit = UnitMenu.initial

    func unitSelection() {
         var unitActions = [UIMenuElement]()
            // グラム
            unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.gram), image: nil, state: self.selectedUnit == UnitMenu.gram ? .on: .off, handler: { (_) in
                self.selectedUnit = .gram
                self.unitSelection()
            }))
            // 個数
            unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.piece), image: nil, state: self.selectedUnit == UnitMenu.piece ? .on:.off, handler: { (_) in
                self.selectedUnit = .piece
                self.unitSelection()
            }))
            unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.bottle), image: nil, state: self.selectedUnit == UnitMenu.bottle ? .on:.off, handler: { (_) in
                self.selectedUnit = .bottle
                self.unitSelection()
            }))
            unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.bag), image: nil, state: self.selectedUnit == UnitMenu.bag ? .on:.off, handler: { (_) in
                self.selectedUnit = .bag
                self.unitSelection()
            }))
            unitActions.append(UIAction(title: unitButtonTranslator(unit: UnitMenu.people), image: nil, state: self.selectedUnit == UnitMenu.people ? .on:.off, handler: { (_) in
                self.selectedUnit = .people
                self.unitSelection()
            }))
            self.menu = UIMenu(title: "", options: .displayInline, children: unitActions)
            self.showsMenuAsPrimaryAction = true
            self.setTitle(unitButtonTranslator(unit: self.selectedUnit), for: .normal)
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
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
