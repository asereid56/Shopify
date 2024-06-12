//
//  GeneralLoginViewController.swift
//  Shopify
//
//  Created by Mina on 27/05/2024.
//

import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CryptoKit
import RxAlamofire
import RxSwift
import UIKit


class GeneralLoginViewController: UIViewController {
    var currentNonce: String?
    var coordinator: MainCoordinator?
    var viewModel: GeneralLoginViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        coordinator?.goToLoginWithEmail()
    }
    
    @IBAction func googleTapped(_ sender: Any) {
            viewModel?.signInWithGoogle(vc: self)
        }
    
    @IBAction func signUpTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
}
