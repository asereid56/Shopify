//
//  SignUpViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class SignUpViewModel {
    func signOut() {
        
    }
    func validateEntries(passTxt: String, confirmPassTxt: String, firstNameTxt: String, lastNameTxt: String, emailTxt: String, vc: UIViewController) {
        if !passTxt.isEmpty && !confirmPassTxt.isEmpty && !firstNameTxt.isEmpty && !lastNameTxt.isEmpty {
            if passTxt == confirmPassTxt {
                AuthenticationManager.signUp(firstname: firstNameTxt, lastName: lastNameTxt, email: emailTxt, password: passTxt, vc: vc)
            } else {
                AuthenticationManager.showAlert(vc: vc, title: "", message: "Passwords Don't Match")
            }
        }
        else {
            AuthenticationManager.showAlert(vc: vc, title: "Empty Fields", message: "Please fill in all the fields")
        }
    }
}
