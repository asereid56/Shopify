//
//  File.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class GeneralLoginViewModel {
    func signInWithGoogle(vc: UIViewController, completion: @escaping (Bool) -> Void) {
        AuthenticationManager.shared.signInWithGoogle(vc: vc) {
            isUserSignedIn in
            if isUserSignedIn {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
}
