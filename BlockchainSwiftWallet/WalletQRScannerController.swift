//
//  WalletQRScannerController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 06/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import AVFoundation
import UIKit

protocol WalletQRScannerControllerDelegate {
    func scannerController(_ scannerController: WalletQRScannerController, didScanPrivateKey privateKey: Data)
    func scannerController(_ scannerController: WalletQRScannerController, failedScanningWithError error: ScanError)
}

enum ScanError: Error {
    case invalidPrivateKey
}

class WalletQRScannerController: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer
    var delegate: WalletQRScannerControllerDelegate
    
    init?(delegate: WalletQRScannerControllerDelegate) {
        self.delegate = delegate
        captureSession = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        super.init()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return nil
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return nil
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return nil
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let privateKeyData = Data(hex: stringValue) {
                delegate.scannerController(self, didScanPrivateKey: privateKeyData)
            } else {
                delegate.scannerController(self, failedScanningWithError: .invalidPrivateKey)
            }
        }
    }
    
    func startScanning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func updatePreviewLayerFrame(_ frame: CGRect, orientation: UIDeviceOrientation) {
        previewLayer.frame = frame
        previewLayer.connection?.videoOrientation = orientation.toVideoOrientation()
    }
}

private extension UIDeviceOrientation {
    func toVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}
