//
//  WalletViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 27/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

private var firstTaken = false

class WalletViewController: UIViewController {
    
    var node: Node!
    
    @IBOutlet weak var viewSelector: UISegmentedControl!
    
    lazy var summaryViewController: WalletSummaryViewController = {
        return storyboard!.instantiateViewController(withIdentifier: "WalletSummary") as! WalletSummaryViewController
    }()

    lazy var nodeViewController: NodeViewController = {
        return storyboard!.instantiateViewController(withIdentifier: "Node") as! NodeViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if node == nil {
            if firstTaken {
                node = Node(address: NodeAddress(host: "localhost", port: UInt32.random(in: 1000...9999)))
            } else {
                node = Node(address: NodeAddress.centralAddress())
                firstTaken = true
            }
            if node.address.isCentralNode {
                let _ = node.mineBlock() // Give ourselves the first block reward
            }
            node.delegate = self
        }

        setupViewSelector()
    }
    
    private func setupViewSelector() {
        viewSelector.removeAllSegments()
        viewSelector.insertSegment(withTitle: "Wallet", at: 0, animated: false)
        viewSelector.insertSegment(withTitle: "Node", at: 1, animated: false)
        viewSelector.selectedSegmentIndex = 0
        viewSelector.sizeToFit()
        viewSelected(sender: viewSelector)
    }
    
    @IBAction
    func viewSelected(sender: Any) {
        if viewSelector.selectedSegmentIndex == 0 {
            add(asChildViewController: summaryViewController)
            nodeViewController.remove()
        } else if viewSelector.selectedSegmentIndex == 1 {
            add(asChildViewController: nodeViewController)
            summaryViewController.remove()
        }
        updateViews()
    }
    
    private func updateViews() {
        nodeViewController.address = node.address
        nodeViewController.peers = node.knownNodes
        nodeViewController.blocks = node.blockchain.blocks
        nodeViewController.mempool = node.mempool
        nodeViewController.utxos = node.blockchain.findSpendableOutputs(for: node.wallet.address)

        let pending = node.mempool.filter { $0.summary().from == self.node.wallet.address }
        let transactions = node.blockchain.findTransactions(for: self.node.wallet.address)
        summaryViewController.transactions = (sent: transactions.sent, received: transactions.received, pending: pending)
        summaryViewController.balance = node.blockchain.balance(for: node.wallet.address)
        summaryViewController.address = node.wallet.address.hex
    }
    
}

extension WalletViewController: NodeDelegate {
    func node(_ node: Node, didReceiveTransactions transactions: [Transaction]) {
        updateViews()
    }

    func node(_ node: Node, didCreateTransactions transactions: [Transaction]) {
        updateViews()
    }
    
    func node(_ node: Node, didSendTransactions transactions: [Transaction]) {
        updateViews()
    }
    
    func node(_ node: Node, didReceiveBlocks blocks: [Block]) {
        updateViews()
    }
    
    func node(_ node: Node, didSendBlocks blocks: [Block]) {
        updateViews()
    }
    
    func node(_ node: Node, didCreateBlocks blocks: [Block]) {
        updateViews()
    }
    
    func node(_ node: Node, didAddPeer: NodeAddress) {
        updateViews()
    }
}
