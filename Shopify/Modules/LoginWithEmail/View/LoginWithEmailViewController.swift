//
//  LoginWithEmailViewController.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import UIKit
import FirebaseAuth
class LoginWithEmailViewController: UIViewController {
    var coordinator: MainCoordinator?
    var viewModel:LoginWithEmailViewModel?
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.isSecureTextEntry = true 
    }
   
    
    @IBAction func loginTapped(_ sender: Any) {
        if checkInternetAndShowToast(vc: self) {
            signin()
        }
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        if checkInternetAndShowToast(vc: self) {
            signInWithGoogle()
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
    

    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
    
    func signin() {
        viewModel?.signInWithEmail(email: emailTxt.text ?? "", password: passwordTxt.text ?? "") { [weak self] success, title, message in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                _ = showToast(message: "Welcome back \(name ?? "")!", vc: self ?? UIViewController())
            } else {
                _ = showToast(message: "Something went wrong, try again", vc: self ?? UIViewController())
            }
        }
    }
    
    func signInWithGoogle() {
        viewModel?.signInWithGoogle(vc: self) { [weak self] success, newUser in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                if newUser {
                    _ = showToast(message: "Welcome \(name ?? "")!", vc: self ?? UIViewController())
                }
                else {
                    _ = showToast(message: "Welcome back\(name ?? "")!", vc: self ?? UIViewController())
                }
            }
            else {
                _ = showToast(message: "Something went wrong, try again", vc: self ?? UIViewController())
            }
        }
    }
    @IBAction func forgotPassTapped(_ sender: Any) {
        coordinator?.goToResetPassword()
    }
}
