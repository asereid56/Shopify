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
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel?.signInWithEmail(email: emailTxt.text ?? "", password: passwordTxt.text ?? "", vc: self)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
    

    @IBAction func backTapped(_ sender: Any) {
        coordinator?.back()
    }
}
