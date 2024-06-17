//
//  SignUpViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class SignUpViewModel {
    
    func validateEntries(passTxt: String, confirmPassTxt: String, firstNameTxt: String, lastNameTxt: String, emailTxt: String, coordinator: MainCoordinator, vc: UIViewController, completion: @escaping (Bool) -> Void) {
        if !passTxt.isEmpty && !confirmPassTxt.isEmpty && !firstNameTxt.isEmpty && !lastNameTxt.isEmpty {
            if passTxt == confirmPassTxt {
                AuthenticationManager.shared.signUp(firstname: firstNameTxt, lastName: lastNameTxt, email: emailTxt, password: passTxt) { success, title, message in
                    if success {
                        completion(true)
                    }
                    else {
                        completion(false)
                        showToast(message: message ?? "", vc: vc)
                    }
                }
            } else {
                AuthenticationManager.shared.showAlert(vc: vc, title: "", message: "Passwords Don't Match")
            }
        }
        else {
            AuthenticationManager.shared.showAlert(vc: vc, title: "Empty Fields", message: "Please fill in all the fields")
        }
    }
    
    func showWelcomeAlert(vc: UIViewController) {
        AuthenticationManager.shared.showWelcomeAlert(vc: vc)
    }
}
