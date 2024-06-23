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
    var passShown = false
    @IBOutlet weak var showPasswordIcon: UIImageView!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.isSecureTextEntry = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleImage(_:)))
        showPasswordIcon.addGestureRecognizer(tapGesture)
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
        indicatorView.isHidden = false
        viewModel?.signInWithEmail(email: emailTxt.text ?? "", password: passwordTxt.text ?? "") { [weak self] success, title, message in
            self?.indicatorView.isHidden = true
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                _ = showAlert(message: "Welcome back \(name ?? "")!", vc: self ?? UIViewController())
            } else {
                _ = showAlert(title: title, message: message!, vc: self ?? UIViewController(), dismissAfter: 2)
            }
        }
    }
    
    func signInWithGoogle() {
        viewModel?.signInWithGoogle(vc: self) { [weak self] success, newUser in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                if newUser {
                    _ = showAlert(message: "Welcome \(name ?? "")!", vc: self ?? UIViewController())
                }
                else {
                    _ = showAlert(message: "Welcome back\(name ?? "")!", vc: self ?? UIViewController())
                }
            }
            else {
                _ = showAlert(message: "Something went wrong, try again", vc: self ?? UIViewController())
            }
        }
    }
    @IBAction func forgotPassTapped(_ sender: Any) {
        coordinator?.goToResetPassword()
    }
    @objc func toggleImage(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
            toggleImage()
            
        }
    }
    func toggleImage() {
        passShown = !passShown
        showPasswordIcon.image = 
            passShown ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
}
