//
//  FirstViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 17/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

class WalletSummaryViewController: UITableViewController {
    @IBOutlet weak var balanceCell: UITableViewCell!
    @IBOutlet weak var addressCell: UITableViewCell!
    @IBOutlet weak var createTransationCell: UITableViewCell!
    @IBOutlet weak var transactionsCell: UITableViewCell!
    @IBOutlet weak var utxosCell: UITableViewCell!
    @IBOutlet weak var exportWalletCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balanceCell.textLabel?.text = "\(balance)"
        addressCell.textLabel?.text = address
        transactionsCell.detailTextLabel?.text = "\(transactions.sent.count + transactions.received.count + transactions.pending.count)"
        utxosCell.detailTextLabel?.text = "\(self.utxos.count)"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) == createTransationCell {
            createTransaction()
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView.cellForRow(at: indexPath) == transactionsCell {
            showTransactionHistory()
        } else if tableView.cellForRow(at: indexPath) == addressCell {
            copyWalletAddress()
            showWalletAddress()
        } else if tableView.cellForRow(at: indexPath) == utxosCell {
            showUTXOs()
        } else if tableView.cellForRow(at: indexPath) == exportWalletCell {
            showWalletExport()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    var balance: UInt64 = 0 {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    let btc = Blockchain.Coin.coinValue(satoshis: self.balance)
                    self.balanceCell.textLabel?.text = String(format: "%.8f BTC", btc)
                }
            }
        }
    }

    var address: String = "" {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.addressCell.textLabel?.text = self.address
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var utxos: [UnspentTransaction] = [] {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.utxosCell.detailTextLabel?.text = "\(self.utxos.count)"
                }
            }
        }
    }

    var transactions: (sent: [Transaction], received: [Transaction], pending: [Transaction]) = (sent: [], received: [], pending: []) {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.transactionsCell.detailTextLabel?.text = "\(self.transactions.sent.count + self.transactions.received.count + self.transactions.pending.count)"
                }
            }
        }
    }

    private func createTransaction() {
        if let wvc = parent as? WalletViewController {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "CreateTransaction") as! CreateTransactionViewController
            viewController.node = wvc.node
            viewController.wallet = wvc.wallet
            viewController.title = "New transaction"
            show(viewController, sender: self)
        }
    }
    
    private func showTransactionHistory() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "My transactions"
        viewController.data = [
            (sectionName: "Received", sectionData: transactions.received.map { ReceivedTransactionCellDataProvider(transaction: $0)}),
            (sectionName: "Sent", sectionData: transactions.sent.map { SentTransactionCellDataProvider(transaction: $0) }),
                (sectionName: "Pending", sectionData: transactions.pending.map { SentTransactionCellDataProvider(transaction: $0) })
        ]
        show(viewController, sender: self)
    }
    
    private func showUTXOs() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "Unspent transactions"
        viewController.data = [(sectionName: "", sectionData: utxos.map { UTXODataProvider(utxo: $0) })]
        show(viewController, sender: self)
    }
    
    private func copyWalletAddress() {
        UIPasteboard.general.string = address
    }
    
    private func showWalletAddress() {
        if let qrImage = address.generateQRCode() {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "WalletExport") as! WalletExportViewController
            viewController.title = "Wallet address"
            viewController.qrImage = UIImage(ciImage: qrImage)
            show(viewController, sender: self)
        }
    }
    
    private func showWalletExport() {
        if let wvc = parent as? WalletViewController, let qrImage = wvc.wallet.secPrivateKey.generateQRCode() {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "WalletExport") as! WalletExportViewController
            viewController.title = "Wallet private key"
            viewController.qrImage = UIImage(ciImage: qrImage)
            show(viewController, sender: self)
        }
    }
}
