//
//  SignUpViewController.swift
//  Shopify
//
//  Created by Aser Eid on 26/05/2024.
//

import UIKit

class SignUpViewController: UIViewController{
    var coordinator: MainCoordinator?
    var viewModel: SignUpViewModel?
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.isSecureTextEntry = true
        confirmPasswordTxt.isSecureTextEntry = true
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
        viewModel?.validateEntries(passTxt: passwordTxt.text!, confirmPassTxt: confirmPasswordTxt.text!, firstNameTxt: firstNameTxt.text!, lastNameTxt: lastNameTxt.text!, emailTxt: emailTxt.text!, coordinator: MainCoordinator(navigationController: UINavigationController()), vc: self) { [weak self] success in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()?.capitalized
                self?.coordinator?.gotoTab()
                _ = showToast(message: "Welcome \(name ?? "")!", vc: self ?? UIViewController()) {
                    let action1 = UIAlertAction(title: "Dismiss", style: .cancel)
                    _ = showToast(title: "Email Verification Required", message: "Please note you must verify your email address to be able to use your cart", vc: self ?? UIViewController(), actions: [action1], style: .alert, selfDismiss: false)
                }
            }
            else {
                _ = showToast(message: "Something went wrong, try again", vc: self ?? UIViewController())
            }
        }
    }
}
