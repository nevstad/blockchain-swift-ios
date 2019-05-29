//
//  WalletCreateViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 27/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

protocol WalletCreateDelegate {
    func walletCreated(_ wallet: Wallet)
}
class WalletCreateViewController: UIViewController {
    @IBOutlet weak var walletNameField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    enum Mode {
        case create(allowCancel: Bool)
        case restore(allowCancel: Bool, privateKey: Data)
        case edit(wallet: Wallet)
    }
    
    var delegate: WalletCreateDelegate?
    var walletCreated: ((Wallet) -> Void)?
    var mode: Mode?
    var existingWalletNames: [String] = []
    var editWallet: Wallet?
    var restorePrivateKey: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mode = mode {
            switch mode {
            case .create(let allowCancel):
                title = "Create wallet"
                createButton.setTitle("Create", for: .normal)
                if allowCancel {
                    addCancelBarButtonItem()
                }
            case .edit(let wallet):
                title = "Edit wallet"
                createButton.setTitle("Save", for: .normal)
                editWallet = wallet
                addCancelBarButtonItem()
            case .restore(let allowCancel, let privateKey):
                title = "Restore wallet"
                createButton.setTitle("Restore", for: .normal)
                restorePrivateKey = privateKey
                if allowCancel {
                    addCancelBarButtonItem()
                }
            }
        } else {
            title = "Create wallet"
            createButton.setTitle("Create", for: .normal)
        }
        
        existingWalletNames = Keygen.avalaibleKeyPairsNames()
        walletNameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func addCancelBarButtonItem() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        closeButton.tintColor = .white
        navigationItem.rightBarButtonItems = [closeButton]
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        validateInput(textField.text ?? "")
    }
    
    private func validateInput(_ input: String) {
        if existingWalletNames.contains(input) {
            createButton.isEnabled = false
            errorLabel.text = "⚠️ You already have a wallet with that name"
        } else {
            createButton.isEnabled = !input.isEmpty
            errorLabel.text = input.isEmpty ? "Please enter a wallet name" : ""
        }
    }
    
    @IBAction func createWallet(_ sender: Any) {
        if let walletName = walletNameField.text {
            if let wallet = editWallet {
                delegate?.walletCreated(wallet)
                walletCreated?(wallet)
            } else {
                if let privateKey = restorePrivateKey {
                    if let wallet = Wallet(name: walletName, privateKeyData: privateKey, storeInKeychain: true) {
                        delegate?.walletCreated(wallet)
                        walletCreated?(wallet)
                    } else {
                        showAlert(title: "Could not restore from the specified private key") {
                            self.close()
                        }
                    }
                } else {
                    if let wallet = Wallet(name: walletName, storeInKeychain: true) {
                        delegate?.walletCreated(wallet)
                        walletCreated?(wallet)
                    } else {
                        showAlert(title: "There was an error generating your wallet") {
                            self.close()
                        }
                    }
                }
            }
        }
    }
}


extension WalletCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == walletNameField {
            
        }
        return false
    }
}
