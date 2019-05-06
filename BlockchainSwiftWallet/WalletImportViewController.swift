//
//  WalletImportViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 06/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit
import AVFoundation

class WalletImportViewController: UIViewController, WalletQRScannerControllerDelegate {
    
    var scannerController: WalletQRScannerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scannerController = WalletQRScannerController(delegate: self)
        
        view.backgroundColor = UIColor.black
        view.layer.addSublayer(scannerController.previewLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scannerController.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerController.stopScanning()
    }
    
    func scannerController(_ scannerController: WalletQRScannerController, didScanPrivateKey privateKey: Data) {
        if let wallet = Wallet(name: "Restored", privateKeyData: privateKey) {
            showAlert(title: "Wallet restored", message: wallet.address.hex)
        } else {
            showAlert(title: "Invalid private key")
        }
    }
    
    func scannerController(_ scannerController: WalletQRScannerController, failedScanningWithError error: ScanError) {
        showAlert(title: "Invalid private key")
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scannerController.updatePreviewLayerFrame(view.bounds, orientation: UIDevice.current.orientation)
    }
    
}

