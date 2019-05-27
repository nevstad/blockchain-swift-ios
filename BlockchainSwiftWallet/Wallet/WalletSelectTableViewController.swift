//
//  WalletSelectTableViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 27/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

protocol WalletSelectDelegate {
    func walletSelected(_ wallet: Wallet)
}

class WalletCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
}

class WalletSelectTableViewController: UITableViewController {
    var wallets: [Wallet] = []
    var delegate: WalletSelectDelegate?
    var walletSelected: ((Wallet) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select wallet"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        closeButton.tintColor = .white
        navigationItem.rightBarButtonItems = [closeButton]
        
        wallets = Keygen.avalaibleKeyPairsNames().map { Wallet(name: $0, keyPair: Keygen.loadKeyPairFromKeychain(name: $0)!) }
        tableView.reloadData()
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell") as? WalletCell {
            let wallet = wallets[indexPath.row]
            cell.walletNameLabel.text = wallet.name
            cell.walletAddressLabel.text = wallet.address.hex
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.walletSelected(wallets[indexPath.row])
        walletSelected?(wallets[indexPath.row])
    }
}
