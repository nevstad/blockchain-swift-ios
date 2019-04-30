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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.balanceCell.textLabel?.text = "\(self.balance)"
        self.addressCell.textLabel?.text = self.address
        self.transactionsCell.detailTextLabel?.text = "\(self.transactions.sent.count + self.transactions.received.count + self.transactions.pending.count)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) == createTransationCell {
            createTransaction()
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView.cellForRow(at: indexPath) == transactionsCell {
            viewTransactions()
        } else if tableView.cellForRow(at: indexPath) == addressCell {
            copyWalletAddress()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var balance: UInt64 = 0 {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.balanceCell.textLabel?.text = "\(self.balance)"
                }
            }
        }
    }

    var address: String = "" {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.addressCell.textLabel?.text = self.address
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
            var recipient: Data = Data()
            if let copiedAddressString = UIPasteboard.general.string, let copiedAddress = Data(hex: copiedAddressString) {
                recipient = copiedAddress
            }
            do {
                let _ = try wvc.node.createTransaction(recipientAddress: recipient, value: 1)
            } catch Node.TxError.insufficientBalance {
                showError(title: "Insufficient balance")
            } catch Node.TxError.invalidValue {
                showError(title: "Invalid value")
            } catch Node.TxError.unverifiedTransaction {
                showError(title: "Unable to verify transaction")
            } catch Node.TxError.sourceEqualDestination {
                showError(title: "You can't send to yourself")
            } catch {
                showError(title: "Undefined error")
            }
        }
    }
    
    private func viewTransactions() {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "My Transactions"
        viewController.data = [
                (sectionName: "Received", sectionData: transactions.received as [GenericCellDataProvider]),
                (sectionName: "Sent", sectionData: transactions.sent as [GenericCellDataProvider]),
                (sectionName: "Pending", sectionData: transactions.pending as [GenericCellDataProvider])
        ]
        show(viewController, sender: self)
    }
    
    private func copyWalletAddress() {
        UIPasteboard.general.string = address
    }
}
