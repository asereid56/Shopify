//
//  TabBar.swift
//  Shopify
//
//  Created by Aser Eid on 02/06/2024.
//

import Foundation
import UIKit

class TabBar : UITabBarController , Storyboarded {
    
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        
        let homeScreen = storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        
        let categoryScreen = storyboard?.instantiateViewController(withIdentifier: "CategoryScreenViewController") as! CategoryScreenViewController
        
        let profileScreen = storyboard?.instantiateViewController(identifier: "ProfileScreenViewController") as! ProfileScreenViewController
        
        homeScreen.coordinator = coordinator
        categoryScreen.coordinator = coordinator
        profileScreen.coordinator = coordinator
        
        let homeScreenViewModel = HomeScreenViewModel(network: NetworkService.shared)
        homeScreen.viewModel = homeScreenViewModel
        
        let categoryScreenViewModel = CategoryScreenViewModel(network: NetworkService.shared)
        categoryScreen.viewModel = categoryScreenViewModel
        
        viewControllers = [homeScreen , categoryScreen , profileScreen]
    
    }
    
}
