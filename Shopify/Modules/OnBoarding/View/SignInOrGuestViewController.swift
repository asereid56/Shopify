//
//  SignInOrGuestViewController.swift
//  Shopify
//
//  Created by Aser Eid on 16/06/2024.
//

import UIKit

class SignInOrGuestViewController: UIViewController , Storyboarded{

    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        coordinator?.goToMainLogin()
    }
    
    
    @IBAction func guestBtn(_ sender: Any) {
        coordinator?.gotoTab()
    }
    

}
