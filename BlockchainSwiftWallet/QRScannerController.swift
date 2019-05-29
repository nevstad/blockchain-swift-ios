//
//  WalletQRScannerController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 06/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import AVFoundation
import UIKit

enum QRScannerError: Error {
    case noReadableObject
    case noStringValue
}

protocol QRScannerControllerDelegate {
    func scannerController(_ scannerController: QRScannerController, didScanString string: String)
    func scannerController(_ scannerController: QRScannerController, failedScanningWithError error: QRScannerError)
}

class QRScannerController: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer
    var delegate: QRScannerControllerDelegate
    
    init?(delegate aDelegate: QRScannerControllerDelegate) {
        delegate = aDelegate
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
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                delegate.scannerController(self, failedScanningWithError: .noReadableObject)
                return
            }
            guard let stringValue = readableObject.stringValue else {
                delegate.scannerController(self, failedScanningWithError: .noStringValue)
                return
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate.scannerController(self, didScanString: stringValue)
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
