//
//  UnitSelectButton.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//
///参考１：https://qiita.com/takashico/items/3a94831801869f4203f2
///2：https://note.com/creative_life/n/n2f4eb376c568

import UIKit

class UnitSelectButton: UIButton {
    enum UnitMenu: String {
    case initial = "単位を選択してください"
    case gram = "g"
    case piece = "個"
    case bottle = "本"
    case bag = "袋"
    case people = "人分"
    }
    
    var selectedUnit = UnitMenu.initial
    
    func unitSelection() {
         var unitActions = [UIMenuElement]()
        //グラム
        unitActions.append(UIAction(title: UnitMenu.gram.rawValue, image: nil, state: self.selectedUnit == UnitMenu.gram ? .on: .off, handler: { (_) in
            self.selectedUnit = .gram
            self.unitSelection()
        }))
        // 個数
        unitActions.append(UIAction(title: UnitMenu.piece.rawValue, image: nil, state: self.selectedUnit == UnitMenu.piece ? .on:.off, handler: { (_) in
            self.selectedUnit = .piece
            self.unitSelection()
        }))
        unitActions.append(UIAction(title: UnitMenu.bottle.rawValue, image: nil, state: self.selectedUnit == UnitMenu.bottle ? .on:.off, handler: { (_) in
            self.selectedUnit = .bottle
            self.unitSelection()
        }))
        unitActions.append(UIAction(title: UnitMenu.bag.rawValue, image: nil, state: self.selectedUnit == UnitMenu.bag ? .on:.off, handler: { (_) in
            self.selectedUnit = .bag
            self.unitSelection()
        }))
        unitActions.append(UIAction(title: UnitMenu.people.rawValue, image: nil, state: self.selectedUnit == UnitMenu.people ? .on:.off, handler: { (_) in
            self.selectedUnit = .people
            self.unitSelection()
        }))
        self.menu = UIMenu(title: "", options: .displayInline, children: unitActions)
        self.showsMenuAsPrimaryAction = true
        self.setTitle(self.selectedUnit.rawValue, for: .normal)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
