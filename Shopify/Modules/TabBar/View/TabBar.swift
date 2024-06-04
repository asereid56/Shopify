//
//  TabBar.swift
//  Shopify
//
//  Created by Aser Eid on 02/06/2024.
//

import Foundation
import UIKit

class TabBar : UITabBarController {
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        
        let homeScreen = storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        
        let categoryScreen = storyboard?.instantiateViewController(withIdentifier: "CategoryScreenViewController") as! CategoryScreenViewController
        
        homeScreen.coordinator = coordinator
        categoryScreen.coordinator = coordinator
        
        viewControllers = [homeScreen , categoryScreen]
    
    }
    
}
