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
        viewModel?.validateEntries(passTxt: passwordTxt.text!, confirmPassTxt: confirmPasswordTxt.text!, firstNameTxt: firstNameTxt.text!, lastNameTxt: lastNameTxt.text!, emailTxt: emailTxt.text!, vc: self)
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        coordinator?.goToLoginWithEmail()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
}
