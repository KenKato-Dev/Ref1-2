//
//  AccountInformationViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import UIKit

class AccountInformationViewController: UIViewController {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountEmailLabel: UILabel!
    @IBOutlet weak var accountCreatedDayLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    private let accountInformationPresenter = AccountInformatonPresenter(accountInformation: AccountInformation())
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountInformationPresenter.setOutput(accountInformationPresenterOutput: self)
        self.accountInformationPresenter.displayAccountInformation()
        self.signOutButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapSignOutButton()
        }), for: .touchUpInside)
    }
}
extension AccountInformationViewController: AccountInformationPresenterOutput {
    func setAccountInformation(_ name: String, _ email: String, _ criatedDay: String) {
        self.accountNameLabel.text = name
        self.accountEmailLabel.text = email
        self.accountCreatedDayLabel.text = criatedDay
    }
    func moveToRootVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
