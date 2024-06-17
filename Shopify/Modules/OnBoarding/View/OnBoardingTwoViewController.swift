//
//  OnBoardingTwoViewController.swift
//  Shopify
//
//  Created by Aser Eid on 14/06/2024.
//

import UIKit

class OnBoardingTwoViewController: UIViewController , Storyboarded {

    var coordinator : MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
    }
    

    @IBAction func nextBtn(_ sender: Any) {
        coordinator?.goToOnBoardingThirdScreen()
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        coordinator?.goToMainLogin()
    }
    
}
