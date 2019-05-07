//
//  QRScannerViewController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 07/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController {
    
    var scannerController: QRScannerController!
    var delegate: QRScannerControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scannerController = QRScannerController(delegate: delegate)
        
        view.backgroundColor = UIColor.black
        view.layer.addSublayer(scannerController.previewLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerController.startScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scannerController.stopScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scannerController.updatePreviewLayerFrame(view.bounds, orientation: UIDevice.current.orientation)
    }
    
}
