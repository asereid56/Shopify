//
//  File.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
class GeneralLoginViewModel {
    func signInWithGoogle(vc: UIViewController) {
        AuthenticationManager.signInWithGoogle(vc: vc) {
            isUserSignedIn in
            if isUserSignedIn == true {
                AuthenticationManager.showWelcomeAlert(vc: vc)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    vc.dismiss(animated: true)
                }
            }
            else {
                AuthenticationManager.showWelcomeAlert(vc: vc)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let castVC = vc as! GeneralLoginViewController
                    castVC.coordinator?.goToHomeScreen()
                }
            }
        }
    }
}
