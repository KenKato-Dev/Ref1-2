//
//  ShoppingListPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/04/30.
//

import Foundation
protocol ShoppingListPresenterOutput: AnyObject {

}
final class ShoppingListPresenter {
    private weak var shoppingListPresenterOutput: ShoppingListPresenterOutput?

    func setOutput(shoppingListPresenterOutput: ShoppingListPresenterOutput) {
        self.shoppingListPresenterOutput = shoppingListPresenterOutput
    }
}
