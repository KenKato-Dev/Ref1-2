//
//  AccountInformationPresenter.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import Firebase
import Foundation
import MessageUI

protocol AccountInformationPresenterOutput: AnyObject {
    func setAccountInformation(_ name: String, _ email: String, _ criatedDay: String)
    func moveToRootVC()
    func presentEmailView()
    func showAlartIfNeeded(_ message: String)
    func showAlartBeforeSignOut(_ message: String)
    func setUpForAnonymous()
    func showAlartBeforePlivacyPolicy(_ title: String, _ message: String)
    func showAlartBeforeAccountDelete(_ message: String)
    func presentsignUpfromAccountView()
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

    func displayForAnonymous() {
        guard let user = auth.currentUser else { return }
        if user.isAnonymous {
            accountInformationPresenterOutput?.setUpForAnonymous()
        }
    }

    func signOutAction() {
        accountInformation.signOut { result in
            switch result {
            case .success:
                self.accountInformationPresenterOutput?.moveToRootVC()
            case .failure:
                self.accountInformationPresenterOutput?.showAlartIfNeeded("ログアウトに失敗しました")
            }
        }
    }

    func didTapSignOutButton() {
        accountInformationPresenterOutput?.showAlartBeforeSignOut("ログアウトしますか？")
    }

    func didTapEmailButton() {
        accountInformationPresenterOutput?.presentEmailView()
    }

    func privacyPolicyAction() {
        guard let url = URL(string: "https://kenkato-dev.github.io/RefManager.github.io/") else { return }
        UIApplication.shared.open(url)
    }

    func didTapPrivacyPolicyButton() {
        accountInformationPresenterOutput?.showAlartBeforePlivacyPolicy("プライバシーポリシーを開きますか？", "外部リンクにアクセスします")
    }

    func deleteAccountAction() {
        accountInformation.deleteAccount { result in
            switch result {
            case .success:
                self.accountInformationPresenterOutput?.moveToRootVC()
                self.accountInformationPresenterOutput?.showAlartIfNeeded("アカウントを削除しました")
            case .failure:
                self.accountInformationPresenterOutput?.showAlartIfNeeded("アカウント削除に失敗しました")
            }
        }
    }

    func didTapDeleteAccountButton() {
        accountInformationPresenterOutput?.showAlartBeforeAccountDelete("アカウントを削除しますか？")
    }

    func didTapSignUpfromAccountView() {
        accountInformationPresenterOutput?.presentsignUpfromAccountView()
    }
}
