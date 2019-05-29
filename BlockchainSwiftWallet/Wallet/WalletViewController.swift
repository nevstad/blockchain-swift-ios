//
//  WalletViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 27/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

private var centralNodeSetup = false

class WalletViewController: UIViewController {
    var node: Node!
    var wallet: Wallet!
    
    @IBOutlet weak var viewSelector: UISegmentedControl!
    
    lazy var summaryViewController: WalletSummaryViewController = {
        return storyboard!.instantiateViewController(withIdentifier: "WalletSummary") as! WalletSummaryViewController
    }()

    lazy var nodeViewController: NodeViewController = {
        return storyboard!.instantiateViewController(withIdentifier: "Node") as! NodeViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let state = Node.loadState()
        node = Node(type: .peer, blockchain: state.blockchain, mempool: state.mempool)
        wallet = Wallet(name: "Random wallet")
        node.delegate = self
        node.connect()

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)

        setupViewSelector()
        
        showCreateWallet(mode: .create(allowCancel: true))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        node.disconnect()
        node.saveState()
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        node.connect()
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
        title = wallet.name
        
        nodeViewController.peers = node.peers
        nodeViewController.blocks = node.blockchain.blocks
        nodeViewController.mempool = node.mempool
        nodeViewController.utxos = node.blockchain.utxos
        nodeViewController.minerAddress = wallet.address

        summaryViewController.balance = node.blockchain.balance(for: wallet.address)
        summaryViewController.address = wallet.address.hex
        summaryViewController.utxos = node.blockchain.findSpendableOutputs(for: wallet.address)
        let pending = node.mempool.filter { $0.summary().from == wallet.address }
        let transactions = node.blockchain.findTransactions(for: wallet.address)
        summaryViewController.transactions = (sent: transactions.sent, received: transactions.received, pending: pending)
    }
    
    func showWalletSelect() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WalletSelect") as? WalletSelectTableViewController {
            vc.walletSelected = { wallet in
                vc.dismiss(animated: true)
                self.wallet = wallet
                self.updateViews()
            }
            vc.modalPresentationStyle = .pageSheet
            vc.isModalInPopover = true
            navigationController?.present(UINavigationController(rootViewController: vc), animated: true)
        }
    }
    
    func showCreateWallet(mode: WalletCreateViewController.Mode) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WalletCreate") as? WalletCreateViewController {
            vc.mode = mode
            vc.walletCreated = { wallet in
                vc.dismiss(animated: true)
                self.wallet = wallet
                self.updateViews()
            }
            vc.modalPresentationStyle = .pageSheet
            vc.isModalInPopover = true
            navigationController?.present(UINavigationController(rootViewController: vc), animated: true)
        }
    }
}

extension WalletViewController: NodeDelegate {
    func nodeDidConnectToNetwork(_ node: Node) {
        
    }
    
    func node(_ node: Node, didReceiveTransactions transactions: [Transaction]) {
        nodeViewController.mempool = node.mempool
    }

    func node(_ node: Node, didCreateTransactions transactions: [Transaction]) {
        nodeViewController.mempool = node.mempool
        nodeViewController.utxos = node.blockchain.utxos
        
        summaryViewController.balance = node.blockchain.balance(for: wallet.address)
        summaryViewController.utxos = node.blockchain.findSpendableOutputs(for: wallet.address)
        let pending = node.mempool.filter { $0.summary().from == wallet.address }
        let transactions = node.blockchain.findTransactions(for: wallet.address)
        summaryViewController.transactions = (sent: transactions.sent, received: transactions.received, pending: pending)
    }
    
    func node(_ node: Node, didSendTransactions transactions: [Transaction]) {}
    
    func node(_ node: Node, didReceiveBlocks blocks: [Block]) {
        nodeViewController.blocks = node.blockchain.blocks
        nodeViewController.mempool = node.mempool
        nodeViewController.utxos = node.blockchain.utxos
        
        summaryViewController.balance = node.blockchain.balance(for: wallet.address)
        summaryViewController.utxos = node.blockchain.findSpendableOutputs(for: wallet.address)
        let pending = node.mempool.filter { $0.summary().from == wallet.address }
        let transactions = node.blockchain.findTransactions(for: wallet.address)
        summaryViewController.transactions = (sent: transactions.sent, received: transactions.received, pending: pending)
    }
    
    func node(_ node: Node, didSendBlocks blocks: [Block]) {}
    
    func node(_ node: Node, didCreateBlocks blocks: [Block]) {
        nodeViewController.blocks = node.blockchain.blocks
        nodeViewController.mempool = node.mempool
        nodeViewController.utxos = node.blockchain.utxos
        
        summaryViewController.balance = node.blockchain.balance(for: wallet.address)
        summaryViewController.utxos = node.blockchain.findSpendableOutputs(for: wallet.address)
        let pending = node.mempool.filter { $0.summary().from == wallet.address }
        let transactions = node.blockchain.findTransactions(for: wallet.address)
        summaryViewController.transactions = (sent: transactions.sent, received: transactions.received, pending: pending)
    }
    
    func node(_ node: Node, didAddPeer: NodeAddress) {
        nodeViewController.peers = node.peers
    }
}
