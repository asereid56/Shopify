//
//  SignUpViewController.swift
//  Shopify
//
//  Created by Aser Eid on 26/05/2024.
//

import UIKit

class SignUpViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var confirmPassIcon: UIImageView!
    @IBOutlet weak var passIcon: UIImageView!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var firstNameTxt: UITextField!
    
    var coordinator: MainCoordinator?
    var viewModel: SignUpViewModel?
    var passShown = false
    var confirmPassShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.isSecureTextEntry = true
        confirmPasswordTxt.isSecureTextEntry = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleImage(_:)))
        passIcon.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(toggleConfirmImage(_:)))
        confirmPassIcon.addGestureRecognizer(tapGesture1)
    }
    
    @IBAction func signupButton(_ sender: Any) {
        if checkInternetAndShowToast(vc: self) {
            signup()
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        coordinator?.goToLogin()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
    
    func signup() {
        indicatorView.isHidden = false
        viewModel?.validateEntries(passTxt: passwordTxt.text!, confirmPassTxt: confirmPasswordTxt.text!, firstNameTxt: firstNameTxt.text!, lastNameTxt: lastNameTxt.text!, emailTxt: emailTxt.text!, coordinator: MainCoordinator(navigationController: UINavigationController()), vc: self) {
            [weak self] success in
            self?.indicatorView.isHidden = true
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()?.capitalized
                self?.coordinator?.gotoTab()
                _ = showAlert(message: "Welcome \(name ?? "")!", vc: self ?? UIViewController()) {
                    let action1 = UIAlertAction(title: "Dismiss", style: .cancel)
                    _ = showAlert(title: "Email Verification Required", message: "We've sent you an email with the link to verify your email", vc: self ?? UIViewController(), actions: [action1], style: .alert, selfDismiss: false)
                }
            }
            else {
                _ = showAlert(message: "Something went wrong, try again", vc: self ?? UIViewController())
            }
        }
    }
    @objc func toggleImage(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
            toggleImage()
            
        }
    }
    func toggleImage() {
        passShown = !passShown
        passIcon.image =
        passShown ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    @objc func toggleConfirmImage(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            confirmPasswordTxt.isSecureTextEntry = !confirmPasswordTxt.isSecureTextEntry
            toggleConfirmImage()
        }
    }
    
    func toggleConfirmImage() {
        confirmPassShown = !confirmPassShown
        confirmPassIcon.image =
        confirmPassShown ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
}
