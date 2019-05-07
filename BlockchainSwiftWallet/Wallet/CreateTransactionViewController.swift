//
//  CreateTransactionViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 07/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

class CreateTransactionViewController: UIViewController, QRScannerControllerDelegate {
    var wallet: Wallet!
    var node: Node!
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField! {
        didSet {
            valueTextField.addSendToolbar(onDone: (target: self, action: #selector(send(_:))))
        }
    }
    
    var scannerViewController: QRScannerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let copiedAddress = UIPasteboard.general.string, copiedAddress.isValidWalletAddress {
            addressTextField.text = copiedAddress
        }
    }
    
    @IBAction func scan(_ sender: Any) {
        scannerViewController = QRScannerViewController()
        scannerViewController?.delegate = self
        scannerViewController?.title = "Scan address"
        show(scannerViewController!, sender: self)
    }
    
    @IBAction func all(_ sender: Any) {
        let balance = node.blockchain.balance(for: wallet.address)
        let coinValue = Blockchain.Coin.coinValue(satoshis: balance)
        valueTextField.text = "\(coinValue)"
    }
    
    @IBAction func send(_ sender: Any) {
        guard let recipient = addressTextField.text, recipient.isValidWalletAddress else {
            showAlert(title: "You must enter a valid address")
            return
        }
        guard let valueString = valueTextField.text, let value = Double(valueString) else {
            showAlert(title: "You must enter a valid value")
            return
        }
        do {
            let satoshis = Blockchain.Coin.satoshisValue(coinValue: value)
            let _ = try node.createTransaction(sender: wallet, recipientAddress: Data(hex: recipient)!, value: satoshis)
            navigationController?.popViewController(animated: true)
        } catch Node.TxError.insufficientBalance {
            showAlert(title: "Insufficient balance")
        } catch Node.TxError.invalidValue {
            showAlert(title: "Invalid value")
        } catch Node.TxError.unverifiedTransaction {
            showAlert(title: "Unable to verify transaction")
        } catch Node.TxError.sourceEqualDestination {
            showAlert(title: "You can't send to yourself")
        } catch {
            showAlert(title: "Undefined error")
        }
    }
    
    func scannerController(_ scannerController: QRScannerController, didScanString string: String) {
        if string.isValidWalletAddress {
            navigationController?.popViewController(animated: true)
            addressTextField.text = string
            addressTextField.resignFirstResponder()
            valueTextField.becomeFirstResponder()
        } else {
            scannerViewController?.showAlert(title: "Invalid address") {
                self.scannerViewController?.scannerController.startScanning()
            }
        }
        
    }
    
    func scannerController(_ scannerController: QRScannerController, failedScanningWithError error: QRScannerError) {
        scannerViewController?.showAlert(title: "Failed to scan") {
            self.scannerViewController?.scannerController.startScanning()
        }
    }

}

extension CreateTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == addressTextField {
            valueTextField.becomeFirstResponder()
        } else if textField == valueTextField {
            send(textField)
        }
        return false
    }
}

extension UITextField {
    func addSendToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(resignFirstResponder))
        let onDone = onDone ?? (target: self, action: #selector(resignFirstResponder))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Send", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
}

extension String {
    var isValidWalletAddress: Bool {
        if let data = Data(hex: self) {
            return data.count == 32
        }
        return false
    }
}
