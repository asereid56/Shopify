//
//  GeneralLoginViewController.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import CryptoKit
import UIKit


class GeneralLoginViewController: UIViewController {
    var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AuthenticationManager.isUserLoggedIn())
        
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        print("tapped")
        let emailVC = self.storyboard?.instantiateViewController(identifier: "LoginWithEmailViewController")
        if let emailVC {
            present(emailVC, animated: true)
        }
    }
    
    @IBAction func googleTapped(_ sender: Any) {
        
        AuthenticationManager.signInWithGoogle(vc: self) {
            isUserSignedIn in
            if isUserSignedIn == true {
                AuthenticationManager.showWelcomeAlert(vc: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true)
                }
            }
            else {
                AuthenticationManager.showWelcomeAlert(vc: self)
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(identifier: "signUpViewController")
        if let signUpVC {
            present(signUpVC, animated: true)
        }
    }
}
 

extension GeneralLoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("signing in...")
        guard let nonce = currentNonce else { return }
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let token = appleIDCredential.identityToken else { return }
            guard let tokenString = String(data: token, encoding: .utf8) else { return }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, accessToken: nonce)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error signing in with Apple: \(error.localizedDescription)")
                    return
                }
                let firstName = appleIDCredential.fullName?.givenName
                let lastName = appleIDCredential.fullName?.familyName
                let email = appleIDCredential.email
                print("User signed in with Firebase")
                print("first name: \(firstName ?? "")")
                print("last name: \(lastName ?? "")")
                print("email: \(email ?? "")")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple error: \(error.localizedDescription)")
    }
    
}

//extension GeneralLoginViewController: ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}
