//
//  LoginWithEmailViewController.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import UIKit
import FirebaseAuth
class LoginWithEmailViewController: UIViewController {

    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.isSecureTextEntry = true 
    }
    override func viewDidAppear(_ animated: Bool) {
        //AuthenticationManager.showWelcomeAlert(vc: self)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        AuthenticationManager.signIn(email: emailTxt.text ?? "", password: passwordTxt.text ?? "", vc: self)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(identifier: "signUpViewController")
        if let signUpVC {
            present(signUpVC, animated: true)
        }
    }
    

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
