//
//  LoginWithEmailViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class LoginWithEmailViewModel {
    func signInWithEmail(email: String, password: String, completion: @escaping (Bool, String?, String?) -> Void) {
        
        AuthenticationManager.shared.signIn(email: email, password: password) { success,title,message in 
            
            if success { completion(true, nil, nil) }
            else { completion(false, title, message) }
        }
    }
    func signInWithGoogle(vc: UIViewController, completion: @escaping (Bool, Bool) -> Void) {
        AuthenticationManager.shared.signInWithGoogle(vc: vc) {
            isUserSignedIn, isNewUser in
            if isUserSignedIn {
                if isNewUser {
                    completion(true, true)
                }
                else {
                    completion(true, false)
                }
            }
            else {
                completion(false, false)
            }
        }
    }
}
