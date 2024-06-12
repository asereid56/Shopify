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
  //     let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
//        let homeScreenVC = storyboard.instantiateViewController(withIdentifier: "generalLoginViewController") as! GeneralLoginViewController
        
        //homeScreenVC.coordinator = self
      //  navigationController.pushViewController(homeScreenVC, animated: false)
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let homeScreenVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
//        
//        homeScreenVC.coordinator = self
//        navigationController.pushViewController(homeScreenVC, animated: false)
      //  goToSettings()
       goToShoppingCart()
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
        let viewModel = AddressesViewModel(networkService: NetworkService(), customerId: "7504328687769")
        addressesVC.viewModel = viewModel
        addressesVC.coordinator = self
        navigationController.pushViewController(addressesVC, animated: false)
    }
    
    func goToEditAddress(address : Address){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        let viewModel = NewAddressViewModel(address: address, networkService: NetworkService(), customerId: "7504328687769",dataLoader: DataLoader())
        newAddressVC.viewModel = viewModel
        newAddressVC.coordinator = self
        navigationController.pushViewController(newAddressVC, animated: false)
    }
    
    func goToNewAddress(){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        let viewModel = NewAddressViewModel(networkService: NetworkService(), customerId: "7504328687769",dataLoader: DataLoader())
        newAddressVC.viewModel = viewModel
        newAddressVC.coordinator = self
        navigationController.pushViewController(newAddressVC, animated: false)
    }
    
    func goToAddressMeunList(from viewController: NewAddressViewController, type : ListType , viewModel : NewAddressViewModelProtocol){
        let menuListVC = MenuListViewController.instantiate(storyboardName:"Setting")
        menuListVC.viewModel = viewModel
        menuListVC.type = type
        menuListVC.delegate = viewController
        navigationController.present(menuListVC, animated: true)
    }
    
    func goToShoppingCart() {
        let ShoppingCarVC = ShoppingCartViewController.instantiate(storyboardName:"Setting")
        let viewModel = ShoppingCartViewModel(networkService: NetworkService(), draftOrderId: "1110462660761")
        ShoppingCarVC.viewModel = viewModel
        ShoppingCarVC.coordinator = self
        navigationController.pushViewController(ShoppingCarVC, animated: false)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
}
