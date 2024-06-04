//
//  AddressesViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit

class AddressesViewController: UIViewController ,Storyboarded {
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func goToNewAddress(_ sender: Any) {
        coordinator?.goToNewAddress()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
}
