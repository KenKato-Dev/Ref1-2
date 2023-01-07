//
//  AccountInformationViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import UIKit

class AccountInformationViewController: UIViewController {
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var accountEmailLabel: UILabel!
    @IBOutlet var accountCreatedDayLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    private let accountInformationPresenter = AccountInformatonPresenter(accountInformation: AccountInformation())
    override func viewDidLoad() {
        super.viewDidLoad()
        accountInformationPresenter.setOutput(accountInformationPresenterOutput: self)
        accountInformationPresenter.displayAccountInformation()
        signOutButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapSignOutButton()
        }), for: .touchUpInside)
    }
}

extension AccountInformationViewController: AccountInformationPresenterOutput {
    func setAccountInformation(_ name: String, _ email: String, _ criatedDay: String) {
        accountNameLabel.text = name
        accountEmailLabel.text = email
        accountCreatedDayLabel.text = criatedDay
    }

    func moveToRootVC() {
        navigationController?.popToRootViewController(animated: true)
    }
}
