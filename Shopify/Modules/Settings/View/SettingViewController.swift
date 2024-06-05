//
//  SettingViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit

class SettingViewController: UIViewController, Storyboarded {
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func goToAddresses(_ sender: Any) {
        coordinator?.goToAddresses()
    }
    
    
    @IBAction func goToContactUs(_ sender: Any) {
        coordinator?.goToContactUs()
    }
    
    @IBAction func goToAboutUs(_ sender: Any) {
        coordinator?.goToAboutUs()
    }
}
