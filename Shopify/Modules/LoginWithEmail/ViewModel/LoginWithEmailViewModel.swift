//
//  LoginWithEmailViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class LoginWithEmailViewModel {
    func signInWithEmail(email: String, password: String, vc: UIViewController) {
        AuthenticationManager.signIn(email: email, password: password, vc: vc)
    }
}
