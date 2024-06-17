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
    override func viewDidAppear(_ animated: Bool) {
        
        checkonUserDefaultsValues()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel?.signInWithEmail(email: emailTxt.text ?? "", password: passwordTxt.text ?? "") { [weak self] success, title, message in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                showToast(message: "Welcome back \(name ?? "")!", vc: self ?? UIViewController())
            } else {
                showToast(message: "Something went wrong", vc: self ?? UIViewController())
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
    

    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
}
