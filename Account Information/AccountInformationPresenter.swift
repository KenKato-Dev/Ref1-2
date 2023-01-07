//
//  AccountInformationPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import Firebase
import Foundation

protocol AccountInformationPresenterOutput: AnyObject {
    func setAccountInformation(_ name: String, _ email: String, _ criatedDay: String)
    func moveToRootVC()
}

class AccountInformatonPresenter {
    private let accountInformation: AccountInformation
    private let auth = Auth.auth()
    private weak var accountInformationPresenterOutput: AccountInformationPresenterOutput?
    init(accountInformation: AccountInformation) {
        self.accountInformation = accountInformation
    }

    func setOutput(accountInformationPresenterOutput: AccountInformationPresenterOutput?) {
        self.accountInformationPresenterOutput = accountInformationPresenterOutput
    }

    func displayAccountInformation() {
        accountInformation.fetchUserInfo { result in
            switch result {
            case let .success(user):
                self.accountInformationPresenterOutput?.setAccountInformation(
                    user.userName,
                    user.email,
                    "\(user.createdAt.dateValue().formatted(date: .abbreviated, time: .omitted))"
                )
            case let .failure(error):
                print(error)
            }
        }
    }

    func didTapSignOutButton() {
        do {
            try auth.signOut()
        } catch {}
        accountInformationPresenterOutput?.moveToRootVC()
    }
}
