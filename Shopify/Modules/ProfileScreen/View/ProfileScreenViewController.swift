//
//  ProfileScreenViewController.swift
//  Shopify
//
//  Created by Aser Eid on 03/06/2024.
//

import UIKit

class ProfileScreenViewController: UIViewController {
    
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func settingBtn(_ sender: Any) {
        coordinator?.goToSettings()
    }
    
    
    @IBAction func ordersBtn(_ sender: Any) {
        
    }
    
    @IBAction func wishListBtn(_ sender: Any) {
        coordinator?.goToWishList()
    }
    
}
