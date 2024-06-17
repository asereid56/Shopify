//
//  OrderConfirmedViewController.swift
//  Shopify
//
//  Created by Apple on 16/06/2024.
//

import UIKit

class OrderConfirmedViewController: UIViewController,Storyboarded {
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnGoToOrders(_ sender: Any) {
    }
    
    
    @IBAction func btnContinueShopping(_ sender: Any) {
        coordinator?.gotoTab()
    }
    
}
