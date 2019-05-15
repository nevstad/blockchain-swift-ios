//
//  GenericGroupedTableViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 28/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

typealias GenericTableViewData = [(sectionName: String, sectionData: [GenericCellDataProvider])]

protocol GenericCellDataProvider {
    var title: String { get }
    var detail: String { get }
    var data: GenericTableViewData? { get }
}

class GenericGroupedTableViewController: UITableViewController {

    var data: GenericTableViewData = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].sectionData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].sectionData.isEmpty ? nil : data[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CenericCellReuseIdentifier", for: indexPath)
        
        let item = data[indexPath.section].sectionData[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.accessoryType = item.data != nil ? .disclosureIndicator : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].sectionData.isEmpty ? CGFloat.leastNonzeroMagnitude : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.section].sectionData[indexPath.row]
        if let data = item.data {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
            viewController.data = data
            show(viewController, sender: self)
        }
    }
}

extension Transaction: GenericCellDataProvider {
    var title: String {
        let sum = summary()
        return "😭 \(sum.from.isEmpty ? "Coinbase" : sum.from.hex)\n🤑 \(sum.to.hex)\n💰 \(sum.amount)"
    }
    var detail: String { return "txId: \(txId)" }
    var data: GenericTableViewData? { return nil }
}

extension Block: GenericCellDataProvider {
    var title: String {
        return "🕑 \(Date(timeIntervalSince1970: Double(timestamp)))\n💸 \(transactions.count)"
    }
    var detail: String { return "hash: \(hash.hex)" }
    var data: GenericTableViewData? {
        return [(sectionName: "Transactions", sectionData: transactions.map { $0 as GenericCellDataProvider })]
    }
}

extension String: GenericCellDataProvider {
    var title: String { return "🌐 \(self)" }
    var detail: String { return "Node network address" }
    var data: GenericTableViewData? { return nil }
}

class SentTransactionCellDataProvider: GenericCellDataProvider {
    let title: String
    let detail: String
    let data: GenericTableViewData? = nil
    init(transaction: Transaction) {
        let sum = transaction.summary()
        self.title = "💰 \(sum.amount)\n→ 💳 \(sum.to.hex) (change: \(sum.change))"
        self.detail = transaction.txId
    }
}

class ReceivedTransactionCellDataProvider: GenericCellDataProvider {
    let title: String
    let detail: String
    let data: GenericTableViewData? = nil
    init(transaction: Transaction) {
        let sum = transaction.summary()
        self.title = "📤 \(transaction.isCoinbase ? "Coinbase" : sum.from.readableHex)\n\(Blockchain.Coin.coinValueString(satoshis: sum.amount))"
        self.detail = transaction.txHash.hex
    }
}

class UTXODataProvider: GenericCellDataProvider {
    let title: String
    let detail: String
    let data: GenericTableViewData? = nil
    init(utxo: UnspentTransaction, showOwner: Bool = false) {
        self.title = "💰 \(utxo.output.value)\(showOwner ? "\n→ 💳 \(utxo.output.address.hex)" : "")"
        self.detail = "txId: \(utxo.outpoint.hash.hex)"
    }
}

