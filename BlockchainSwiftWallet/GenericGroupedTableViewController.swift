//
//  GenericGroupedTableViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 28/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit
typealias GenericTableViewSection = (name: String, data: [GenericCellDataProvider])
typealias GenericTableViewData = [GenericTableViewSection]

protocol GenericCellDataProvider {
    var title: String { get }
    var detail: String { get }
    var data: GenericTableViewData? { get }
    var dataTitle: String? { get }
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
        return data[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].data.isEmpty ? nil : data[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CenericCellReuseIdentifier", for: indexPath)
        
        let item = data[indexPath.section].data[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.accessoryType = item.data != nil ? .disclosureIndicator : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].data.isEmpty ? CGFloat.leastNonzeroMagnitude : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.section].data[indexPath.row]
        if let data = item.data {
            let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
            viewController.title = item.dataTitle
            viewController.data = data
            show(viewController, sender: self)
        }
    }
}


//
// MARK: GenericCellDataProviders
//

class BlockCellDataProvider: GenericCellDataProvider {
    var title: String
    var detail: String
    var data: GenericTableViewData?
    var dataTitle: String?
    init(block: Block) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale.current
        let date = formatter.string(from: Date(timeIntervalSince1970: Double(block.timestamp)))
        title =  "\(block.transactions.count) transactions"
        detail = "\(date)"
        data = [
            (name: "Block info", data: [
                SimpleCellDataProvider(title: block.hash.hex, detail: "Hash", data: nil, dataTitle: nil),
                SimpleCellDataProvider(title: block.previousHash.hex.isEmpty ? "Genesis block, no previous hash" : block.previousHash.hex, detail: "Previous hash", data: nil, dataTitle: nil)
                ]
            ),
            (name: "Transactions", data: block.transactions.map { TransactionCellDataProvider(transaction: $0, style: .both) })
        ]
        dataTitle = "Block"
    }
}

struct SimpleCellDataProvider: GenericCellDataProvider {
    var title: String
    var detail: String
    var data: GenericTableViewData? = nil
    var dataTitle: String? = nil
}

class PeerCellDataProvider: GenericCellDataProvider {
    var title: String
    var detail: String { return "Node network address" }
    var data: GenericTableViewData? = nil
    var dataTitle: String? = nil
    init(peer: NodeAddress) {
        title = "🌐 \(peer.urlString)"
    }
}

class TransactionCellDataProvider: GenericCellDataProvider {
    enum DetailStyle {
        case sender
        case receiver
        case both
    }
    let title: String
    let detail: String
    let data: GenericTableViewData? = nil
    var dataTitle: String? = nil
    init(transaction: Transaction, style: DetailStyle = .sender) {
        let sum = transaction.summary()
        title = "💰 \(Blockchain.Coin.coinValue(satoshis: sum.amount))"
        switch style {
        case .sender:
            detail = "📤 \(transaction.isCoinbase ? "Coinbase" : sum.from.hex)"
        case .receiver:
            detail = "📥 \(sum.to.hex)"
        case .both:
            detail = "📤 \(transaction.isCoinbase ? "Coinbase" : sum.from.hex)\n📥 \(sum.to.hex)"
        }
    }
}

class UTXODataProvider: GenericCellDataProvider {
    let title: String
    let detail: String
    let data: GenericTableViewData? = nil
    var dataTitle: String? = nil
    init(utxo: UnspentTransaction, showOwner: Bool = false) {
        title = "💰 \(utxo.output.value)\(showOwner ? "\n💳 \(utxo.output.address.hex)" : "")"
        detail = "txId: \(utxo.outpoint.hash.hex)"
    }
}
