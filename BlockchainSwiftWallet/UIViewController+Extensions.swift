//
//  UIViewController+Extensions.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 30/04/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    internal func showAlert(title: String?, message: String? = nil, button: String = "OK") {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
}
