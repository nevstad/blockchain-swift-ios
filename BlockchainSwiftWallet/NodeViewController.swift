//
//  NodeViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 28/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

class NodeViewController: UITableViewController {
    @IBOutlet weak var nodeAddressCell: UITableViewCell!
    @IBOutlet weak var nodePeersCell: UITableViewCell!
    @IBOutlet weak var lastBlockHashCell: UITableViewCell!
    @IBOutlet weak var blocksCell: UITableViewCell!
    @IBOutlet weak var utxosCell: UITableViewCell!
    @IBOutlet weak var mempoolCell: UITableViewCell!
    @IBOutlet weak var mineBlockCell: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) == blocksCell {
            showBlocks()
        } else if tableView.cellForRow(at: indexPath) == utxosCell {
            showUTXOs()
        } else if tableView.cellForRow(at: indexPath) == mempoolCell {
            showMempool()
        } else if tableView.cellForRow(at: indexPath) == nodeAddressCell {
            UIPasteboard.general.string = address?.urlString
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView.cellForRow(at: indexPath) == nodePeersCell {
            showPeers()
        } else if tableView.cellForRow(at: indexPath) == mineBlockCell {
            showMineBlock()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var address: NodeAddress? {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.nodeAddressCell.textLabel?.text = self.address?.urlString
                }
            }
        }
    }
    
    var minerAddress: Data?
    
    var peers: [NodeAddress] = [] {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.nodePeersCell.detailTextLabel?.text = "\(self.peers.count)"
                }
            }
        }
    }
    
    var blocks: [Block] = [] {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.lastBlockHashCell.textLabel?.text = self.blocks.last?.hash.hex
                    self.blocksCell.detailTextLabel?.text = "\(self.blocks.count)"
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

    var mempool: [Transaction] = [] {
        didSet {
            if viewIfLoaded != nil {
                DispatchQueue.main.async {
                    self.mempoolCell.detailTextLabel?.text = "\(self.mempool.count)"
                }
            }
        }
    }
    
    private func showMempool() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "Transactions"
        viewController.data = [(sectionName: "Mempool", sectionData: mempool as [GenericCellDataProvider])]
        show(viewController, sender: self)
    }
    
    private func showUTXOs() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "UTXOs"
        viewController.data = [(sectionName: "Unspent outputs", sectionData: utxos.map { UTXODataProvider(utxo: $0, showOwner: true) })]
        show(viewController, sender: self)
    }
    
    private func showBlocks() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "Blockchain"
        viewController.data = [(sectionName: "Blocks", sectionData: blocks as [GenericCellDataProvider])]
        show(viewController, sender: self)
    }
    
    private func showPeers() {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "GenericGroupedTableViewController") as! GenericGroupedTableViewController
        viewController.title = "Network"
        viewController.data = [(sectionName: "Peers", sectionData: peers as [GenericCellDataProvider])]
        show(viewController, sender: self)
    }
    
    private func showMineBlock() {
        guard let address = minerAddress else {
            showAlert(title: "Miner address not set")
            return
        }
        if let wvc = parent as? WalletViewController {
            let alert = UIAlertController(title: "Mining block", message: "Please wait", preferredStyle: .alert)
            self.present(alert, animated: true) {
                DispatchQueue.global().async {
                    let _ = wvc.node.mineBlock(minerAddress: address)
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
