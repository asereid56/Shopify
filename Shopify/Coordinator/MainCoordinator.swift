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
        //        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        //        let homeScreenVC = storyboard.instantiateViewController(withIdentifier: "generalLoginViewController") as! GeneralLoginViewController
        //
        //        navigationController.pushViewController(homeScreenVC, animated: false)
        //        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //        let homeScreenVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        //        let homeViewModel = HomeScreenViewModel(network: NetworkService())
        //
        //        homeScreenVC.viewModel = homeViewModel
        //        homeScreenVC.coordinator = self
        //        navigationController.pushViewController(homeScreenVC, animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        
        tabBar.coordinator = self
        navigationController.pushViewController(tabBar, animated: false)
        // goToSettings()
    }
    
    func goToSettings(){
        let settingVC = SettingViewController.instantiate(storyboardName:"Setting")
        settingVC.coordinator = self
        navigationController.pushViewController(settingVC, animated: false)
    }
    
    func goToContactUs(){
        let contactUsVC = ContactUsViewController.instantiate(storyboardName:"Setting")
        contactUsVC.coordinator = self
        navigationController.pushViewController(contactUsVC, animated: false)
    }
    
    func goToAboutUs(){
        let abouttUsVC = AboutUsViewController.instantiate(storyboardName:"Setting")
        abouttUsVC.coordinator = self
        navigationController.pushViewController(abouttUsVC, animated: false)
    }
    
    func goToAddresses(){
        let addressesVC = AddressesViewController.instantiate(storyboardName:"Setting")
        let viewModel = AddressesViewModel(networkService: NetworkService(), customerId: "7484134097049")
        addressesVC.viewModel = viewModel
        addressesVC.coordinator = self
        navigationController.pushViewController(addressesVC, animated: false)
    }
    
    func goToEditAddress(address : Address){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        let viewModel = NewAddressViewModel(address: address, networkService: NetworkService(), customerId: "7484134097049")
        newAddressVC.viewModel = viewModel
        newAddressVC.coordinator = self
        navigationController.pushViewController(newAddressVC, animated: false)
    }
    
    func goToNewAddress(){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        newAddressVC.coordinator = self
        navigationController.pushViewController(newAddressVC, animated: false)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func gotoProductsScreen(with brandId: String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let productScreenVC = storyboard.instantiateViewController(withIdentifier: "ProductsScreenViewController") as! ProductsScreenViewController
        
        let productViewModel = ProductScreenViewModel(network: NetworkService(), brandId: brandId)
        
        productScreenVC.viewModel = productViewModel
        productScreenVC.coordinator = self
        navigationController.pushViewController(productScreenVC, animated: true)
    }
    
    func gotoHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeScreenVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        let homeViewModel = HomeScreenViewModel(network: NetworkService())
        
        homeScreenVC.viewModel = homeViewModel
        homeScreenVC.coordinator = self
        navigationController.pushViewController(homeScreenVC, animated: true)
    }
    
}
