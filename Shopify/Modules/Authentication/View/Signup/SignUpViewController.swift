//
//  SignUpViewController.swift
//  Shopify
//
//  Created by Aser Eid on 26/05/2024.
//

import UIKit

class SignUpViewController: UIViewController {
    
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
        if !passwordTxt.text!.isEmpty && !confirmPasswordTxt.text!.isEmpty {
            if passwordTxt.text == confirmPasswordTxt.text {
                AuthenticationManager.signUp(email: emailTxt.text ?? "", password: passwordTxt.text ?? "", vc: self)
            } else {
                AuthenticationManager.showAlert(vc: self, title: "", message: "Passwords Don't Match")
            }
        }
        else {
            AuthenticationManager.showAlert(vc: self, title: "Empty Fields", message: "Please fill in all the fields")
        }
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        let emailVC = self.storyboard?.instantiateViewController(identifier: "LoginWithEmailViewController")
        if let emailVC {
            present(emailVC, animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
