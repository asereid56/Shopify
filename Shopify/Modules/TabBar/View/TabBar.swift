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
        
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let profileScreen = storyboard.instantiateViewController(identifier: "profileViewController") as! ProfileViewController
        
        homeScreen.coordinator = coordinator
        categoryScreen.coordinator = coordinator
        profileScreen.coordinator = coordinator
        
        let homeScreenViewModel = HomeScreenViewModel(network: NetworkService.shared)
        homeScreen.viewModel = homeScreenViewModel
        
        let categoryScreenViewModel = CategoryScreenViewModel(network: NetworkService.shared)
        categoryScreen.viewModel = categoryScreenViewModel
        
        let profileViewModel = ProfileViewModel(network: NetworkService.shared)
        profileScreen.viewModel = profileViewModel
        viewControllers = [homeScreen , categoryScreen , profileScreen]
    
    }
    
}
