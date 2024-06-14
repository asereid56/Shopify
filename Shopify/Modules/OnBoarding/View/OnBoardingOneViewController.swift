//
//  OnBoardingOneViewController.swift
//  Shopify
//
//  Created by Aser Eid on 14/06/2024.
//

import UIKit

class OnBoardingOneViewController: UIViewController , Storyboarded {

    var coordinator : MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        UserDefaults.standard.set(false, forKey: "isFirstTime")
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        coordinator?.gotoTab()
    }
    
    
    @IBAction func nextBtn(_ sender: Any) {
        coordinator?.goToOnBoardingSecondScreen()

    }
    
}
