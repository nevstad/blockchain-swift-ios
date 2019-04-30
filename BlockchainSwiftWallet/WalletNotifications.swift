//
//  WalletNotifications.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 30/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import Foundation

enum WalletNotificatoins: String {
    case transaction
    case mine
}

class WalletNotificationSender {
    func sendTransactionNotification(recipient: Data, value: UInt64) {
        NotificationCenter.default.post(name: NSNotification.Name(WalletNotificatoins.transaction.rawValue), object: self, userInfo: ["recipient": recipient, "value": value])
    }
    
    func sendMineNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(WalletNotificatoins.mine.rawValue), object: self, userInfo: nil)
    }
}

class WalletNotificationObserver {
    private let transaction: ((Data, UInt64) -> Void)?
    private let mine: (() -> Void)?
    
    init(transaction: ((Data, UInt64) -> Void)?, mine: (() -> Void)?) {
        self.transaction = transaction
        self.mine = mine
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSend(_:)), name: NSNotification.Name(WalletNotificatoins.transaction.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMine(_:)), name: NSNotification.Name(WalletNotificatoins.mine.rawValue), object: nil)
    }
    
    @objc func didReceiveSend(_ notification: Notification) {
        if let recipient = notification.userInfo?["recipient"] as? Data,
            let value = notification.userInfo?["value"] as? UInt64 {
            transaction?(recipient, value)
        }
    }
    
    @objc func didReceiveMine(_ notification: Notification) {
        mine?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
