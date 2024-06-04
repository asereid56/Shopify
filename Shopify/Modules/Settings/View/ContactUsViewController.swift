//
//  ContactUsViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit

class ContactUsViewController: UIViewController , Storyboarded {
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
}