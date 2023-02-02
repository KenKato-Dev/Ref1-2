//
//  AccountInformationViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/12/25.
//

import UIKit
import MessageUI

class AccountInformationViewController: UIViewController {
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var accountEmailLabel: UILabel!
    @IBOutlet var accountCreatedDayLabel: UILabel!
    @IBOutlet weak var signUpfromAccountVCButton: UIButton!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet weak var accontDeleteButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var showPrivacyPolicyButton: UIButton!
    private var mailViewController = MFMailComposeViewController()

    private let accountInformationPresenter = AccountInformatonPresenter(accountInformation: AccountInformation())
    override func viewDidLoad() {
        super.viewDidLoad()
        accountInformationPresenter.setOutput(accountInformationPresenterOutput: self)
        accountInformationPresenter.displayAccountInformation()
        accountInformationPresenter.displayForAnonymous()
        signOutButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapSignOutButton()
        }), for: .touchUpInside)
        sendEmailButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapEmailButton()
        }), for: .touchUpInside)
        showPrivacyPolicyButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapPrivacyPolicyButton()
        }), for: .touchUpInside)
        accontDeleteButton.addAction(.init(handler: { _ in
            self.accountInformationPresenter.didTapDeleteAccountButton()
        }), for: .touchUpInside)
    }
}
extension AccountInformationViewController: MFMailComposeViewControllerDelegate {
    func composeEmailContent() {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        guard MFMailComposeViewController.canSendMail() else {
            print("メール送信不可")
            return
        }

        let emailSendTo = ["katoken.dev@gmail.com"]

        mailViewController.setSubject("冷蔵庫くんへの問い合わせ")
        mailViewController.setToRecipients(emailSendTo)
        mailViewController.setMessageBody("", isHTML: false)
        self.present(mailViewController, animated: true)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var message = ""
                    if let error = error {
                        message = "\(error.localizedDescription)"
                        controller.dismiss(animated: true, completion: nil)
                    }
                    // 結果をハンドリング
                    switch result {
                    case .cancelled: // キャンセル
                        break
                    case .saved: // 下書き保存
                        break
                    case .sent: // 送信された
                        message = "送信に成功しました"
                    case .failed: // 送信失敗
                        message = "送信に失敗しました"
                    default:
                        print("結果がdefault")
                    }
                    // dismiss
                if message != "" {
                    let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    controller.dismiss(animated: true, completion: nil)
                    present(alart, animated: true)
                } else {
                    controller.dismiss(animated: true, completion: nil)
                }
    }
}
extension AccountInformationViewController: AccountInformationPresenterOutput {
    func setAccountInformation(_ name: String, _ email: String, _ criatedDay: String) {
        signUpfromAccountVCButton.isHidden = true
            accountNameLabel.text = name
            accountNameLabel.adjustsFontSizeToFitWidth = true
            accountEmailLabel.text = email
            accountEmailLabel.adjustsFontSizeToFitWidth = true
            accountCreatedDayLabel.text = criatedDay
    }
    func setUpForAnonymous() {
            accountNameLabel.text = "お試し利用中"
            accountEmailLabel.text = "お試し利用中"
            accountCreatedDayLabel.text = "お試し利用中"
            signOutButton.isHidden = true
            sendEmailButton.isHidden = true
    }

    func moveToRootVC() {
        navigationController?.popToRootViewController(animated: true)
    }
    func presentEmailView() {
        self.composeEmailContent()
    }
    func showAlartIfNeeded(_ message: String) {
            let alart = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alart.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alart, animated: true) {}
    }
    func showAlartBeforeSignOut(_ message: String) {
            let alart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alart.addAction(.init(title: "はい", style: .default, handler: { [self] _ in
            self.accountInformationPresenter.signOutAction()
        }))
        alart.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
            present(alart, animated: true) {}
    }
    func showAlartBeforePlivacyPolicy(_ title: String, _ message: String) {
            let alart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alart.addAction(.init(title: "はい", style: .default, handler: { [self] _ in
            self.accountInformationPresenter.privacyPolicyAction()
        }))
        alart.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
            present(alart, animated: true) {}
    }
    func showAlartBeforeAccountDelete(_ message: String) {
        let alart = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alart.addAction(.init(title: "はい", style: .default, handler: { [self] _ in
            self.accountInformationPresenter.deleteAccountAction()
        }))
        alart.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
        present(alart, animated: true) {}
    }
}
