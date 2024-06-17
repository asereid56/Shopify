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
        viewModel?.signInWithGoogle(vc: self) { [weak self] success in
            if success {
                let name = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
                self?.coordinator?.gotoTab()
                showToast(message: "Welcome back \(name ?? "")!", vc: self ?? UIViewController())
            }
            else {
                showToast(message: "Something went wrong", vc: self ?? UIViewController())
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
}
