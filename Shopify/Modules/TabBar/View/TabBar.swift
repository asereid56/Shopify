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
        
        let profileScreen = storyboard?.instantiateViewController(identifier: "ProfileScreenViewController") as! ProfileScreenViewController
        
        let homeViewModel = HomeScreenViewModel(network: NetworkService())
        homeScreen.viewModel = homeViewModel
        
        homeScreen.coordinator = coordinator
        categoryScreen.coordinator = coordinator
        profileScreen.coordinator = coordinator
        
        viewControllers = [homeScreen , categoryScreen , profileScreen]
        
    }
    
}
