//
//  WalletExportViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 05/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

class WalletExportViewController: UIViewController {
    
    var qrImage: UIImage?
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrImageView.image = qrImage
    }
}
