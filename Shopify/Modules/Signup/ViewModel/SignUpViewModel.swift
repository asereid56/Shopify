//
//  SignUpViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit

class SignUpViewModel {
    
    func validateEntries(passTxt: String, confirmPassTxt: String, firstNameTxt: String, lastNameTxt: String, emailTxt: String, coordinator: MainCoordinator, vc: UIViewController, completion: @escaping (Bool, String?, String?) -> Void) {
        if !passTxt.isEmpty && !confirmPassTxt.isEmpty && !firstNameTxt.isEmpty && !lastNameTxt.isEmpty {
            if passTxt == confirmPassTxt {
                AuthenticationManager.shared.signUp(firstname: firstNameTxt, lastName: lastNameTxt, email: emailTxt, password: passTxt) { success, title, message in
                    if success {
                        completion(true, nil, nil)
                    }
                    else {
                        completion(false, title, message)
                        _ = showAlert(message: message ?? "", vc: vc)
                    }
                }
            } else {
                
             //   _ = showAlert(message: "Passwords don't match", vc: vc)
                completion(false, "" , "Passwords don't match")
            }
        }
        else {
          //  _ = showAlert(title: "Empty Fields", message: "Please fill in all the fields", vc: vc)
            completion(false, "Empty Fields" , "Please fill in all the fields")
        }
    }
    
    func showWelcomeAlert(vc: UIViewController) {
        AuthenticationManager.shared.showWelcomeAlert(vc: vc)
    }
}
