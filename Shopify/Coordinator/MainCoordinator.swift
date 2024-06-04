//
//  MainCoordinator.swift
//  Shopify
//
//  Created by Aser Eid on 02/06/2024.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators : [Coordinator] { get set }
    var navigationController : UINavigationController { get set }
    
    func start()
}

class MainCoordinator : Coordinator {
   
    var childCoordinators = [Coordinator]()
    var navigationController : UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        
        tabBar.coordinator = self
        navigationController.pushViewController(tabBar, animated: false)
           
    //    let products = storyboard.instantiateViewController(withIdentifier: "ProductsScreenViewController") as! ProductsScreenViewController
    //    productScreen.coordinator = self
    //    navigationController.pushViewController(products, animated: false)
    }
    
}
