//
//  Authentication.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseCore
import GoogleSignIn
class AuthenticationManager {
    static func signIn(email: String, password: String, vc: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .userDisabled:
                    print("user disabled")
                case .invalidEmail:
                    showAlert(vc: vc, title: "Invalid Email Format", message: "Enter a valid email")
                case .accountExistsWithDifferentCredential:
                    showAlert(vc: vc, title: "Wrong Password", message: "Check your password and try again")
                case .invalidCredential:
                    showAlert(vc: vc, title: "Invalid Credentials", message: "Check your email and password and try again")
                case .wrongPassword:
                    showAlert(vc: vc, title: "Empty Fields", message: "Please fill in email and password fields")
                default:
                    print("Error: \(error)")
                }
            } else {
                showWelcomeAlert(vc: vc)
                
            }
        }
    }
    static func signUp(email: String, password: String, vc: UIViewController){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .operationNotAllowed:
                    print("")
                case .userDisabled:
                    print("user disabled")
                case .weakPassword:
                    showAlert(vc: vc, title: "Weak Password", message: "Your password must be at least 6 characters")
                case .invalidEmail:
                    showAlert(vc: vc, title: "Invalid Email Format", message: "Enter a valid email")
                case .emailAlreadyInUse:
                    showAlert(vc: vc, title: "Registered Email", message: "The email address is already in use by another account.")
                case .missingEmail:
                    showAlert(vc: vc, title: "Empty Email Field", message: "An email address must be provided")
                    
                default:
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signs up successfully")
                let newUserInfo = Auth.auth().currentUser
                let email = newUserInfo?.email
                print(email ?? "")
            }
        }
    }
    
    static func signInWithGoogle(vc: UIViewController, completion: @escaping (Bool) -> Void){
        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
            let user = signInResult?.user
            guard let idToken = user?.idToken else {
                print("AUTHENTICATION ERROR")
                return
            }
            let accessToken = user?.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken!.tokenString)
            Auth.auth().signIn(with: credential){authResult, error in
                guard let authResult else { completion(false); return }
                print("id: \(authResult.user.uid), email: \(authResult.user.email ?? "unknown email")")
                completion(true)
            }
        }
    }
    
    static func showWelcomeAlert(vc: UIViewController){
        print("show welcome alert")
        if let currentUser = Auth.auth().currentUser {
            print("user here")
            let alert = UIAlertController(title: nil, message: "Welcome back \(currentUser.email ?? "")", preferredStyle: .actionSheet)
            vc.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true)
            }
        }
        else {
            print("no user")
            let alert = UIAlertController(title: nil, message: "Please Log in to make use of all features", preferredStyle: .actionSheet)
            vc.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true)
            }
        }
    }
    static func showAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        vc.present(alert, animated: true)
        
    }
    static func isUserLoggedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}




