//
//  AuthenticationController.swift
//  BlockchainSwiftWallet
//
//  Created by Magnus Nevstad on 05/05/2019.
//  Copyright © 2019 Magnus Nevstad. All rights reserved.
//

import Foundation
import LocalAuthentication

class AuthenticationController {
    static func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let localizedReasonString = "Authenticate to access your wallet"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReasonString) { success, error in
                    DispatchQueue.main.async {
                        completion(success, error)
                    }
                }
            } else {
                completion(false, authError)
            }
        } else {
            completion(false, authError)
        }
    }
}
