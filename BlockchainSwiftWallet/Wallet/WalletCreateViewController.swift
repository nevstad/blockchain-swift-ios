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
    var delegate: WalletCreateDelegate?
    var walletCreated: ((Wallet) -> Void)?
    
    @IBOutlet weak var walletNameField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var existingWalletNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create wallet"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        closeButton.tintColor = .white
        navigationItem.rightBarButtonItems = [closeButton]

        existingWalletNames = Keygen.avalaibleKeyPairsNames()
        walletNameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        validateInput("")
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
            errorLabel.text = ""
        }
    }
    
    @IBAction func createWallet(_ sender: Any) {
        if let walletName = walletNameField.text, let wallet = Wallet(name: walletName, storeInKeychain: true) {
            delegate?.walletCreated(wallet)
            walletCreated?(wallet)
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
