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
    
    private let defaults = UserDefaults.standard
    private let key = "isFirstTime"
    var childCoordinators = [Coordinator]()
    var navigationController : UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        if defaults.object(forKey: key) == nil {
            defaults.setValue(true, forKey: key)
        }
        let isFirstTime = defaults.bool(forKey: key)
        
        if isFirstTime == true {
            goToOnBoardingFirstScreen()
        }else{
            gotoTab()
        }

    }
    
    func goToOnBoardingSecondScreen(){
        let onBoardingTwoScreen = OnBoardingTwoViewController.instantiate(storyboardName: "Main")
        onBoardingTwoScreen.coordinator = self
        navigationController.pushViewController(onBoardingTwoScreen, animated: true)
    }
    
    func goToOnBoardingFirstScreen(){
        let onBoardingOneScreen = OnBoardingOneViewController.instantiate(storyboardName: "Main")
        onBoardingOneScreen.coordinator = self
        navigationController.pushViewController(onBoardingOneScreen, animated: true)
    }
    
    func goToSignOrGuestScreen() {
            let signOrGuestVC = SignInOrGuestViewController.instantiate(storyboardName: "Main")
            signOrGuestVC.coordinator = self
            navigationController.pushViewController(signOrGuestVC, animated: true)
        }
    
    func goToOnBoardingThirdScreen(){
        let onBoardingThreeScreen = OnBoardingThreeViewController.instantiate(storyboardName: "Main")
        onBoardingThreeScreen.coordinator = self
        navigationController.pushViewController(onBoardingThreeScreen, animated: true)
    }
    
    func gotoTab(){
        let tabBar = TabBar.instantiate(storyboardName: "Main")
        tabBar.coordinator = self
        navigationController.pushViewController(tabBar, animated: false)
    }
    
    func goToSettings(){
        let settingVC = SettingViewController.instantiate(storyboardName:"Setting")
        let viewModel = SettingViewModel()
        settingVC.viewModel = viewModel
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
    
    func goToAddresses(from viewController: PaymentViewController? = nil , source : String = "setting"){
        let addressesVC = AddressesViewController.instantiate(storyboardName:"Setting")
        let viewModel = AddressesViewModel(networkService: NetworkService.shared, customerId: "7506651938969")
        addressesVC.viewModel = viewModel
        addressesVC.coordinator = self
        addressesVC.source = source
        addressesVC.delegate = viewController
        navigationController.pushViewController(addressesVC, animated: false)
    }
    
    func goToEditAddress(address : Address){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        let viewModel = NewAddressViewModel(address: address, networkService: NetworkService.shared, customerId: "7506651938969",dataLoader: DataLoader())
        newAddressVC.viewModel = viewModel
        newAddressVC.coordinator = self
        navigationController.pushViewController(newAddressVC, animated: false)
    }
    
    func goToNewAddress(){
        let newAddressVC = NewAddressViewController.instantiate(storyboardName:"Setting")
        let viewModel = NewAddressViewModel(networkService: NetworkService.shared, customerId: "7506651938969",dataLoader: DataLoader())
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
        let viewModel = ShoppingCartViewModel(networkService: NetworkService.shared, draftOrderId: "1110462660761", realmManager: RealmManager.shared)
        ShoppingCarVC.viewModel = viewModel
        ShoppingCarVC.coordinator = self
        navigationController.pushViewController(ShoppingCarVC, animated: false)
    }
    
    func goToPayment(draftOrder : DraftOrder){
        let PaymentVC = PaymentViewController.instantiate(storyboardName:"Setting")
        let viewModel = PaymentViewModel(draftOrder: draftOrder, network: NetworkService.shared , customerId: "7506651938969",mockPaymentProcessor: MockPaymentProcessor(), draftOrderId: "1110462660761")
        viewModel.delegate = PaymentVC
        PaymentVC.viewModel = viewModel
        PaymentVC.coordinator = self
        navigationController.pushViewController(PaymentVC, animated: false)
    }
    
    func goToPaymentMethd(from viewController : PaymentViewController){
        let PaymentMethodVC = PaymentMethodViewController.instantiate(storyboardName:"Setting")
        let viewModel = PaymentMethodViewModel()
        PaymentMethodVC.viewModel = viewModel
        PaymentMethodVC.delegate = viewController
        navigationController.present(PaymentMethodVC, animated: true)
    }
    
    func goToOrderConfirmed(){
        let OrderConfirmedVC = OrderConfirmedViewController.instantiate(storyboardName: "Setting")
        OrderConfirmedVC.coordinator = self
        navigationController.pushViewController(OrderConfirmedVC, animated: false)
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
        
    }
    

    func gotoProductsScreen(with brandId: String) {
        
        let productScreenVC = ProductsScreenViewController.instantiate(storyboardName: "Main")
        
        let productViewModel = ProductScreenViewModel(network: NetworkService.shared, brandId: brandId)
        
        productScreenVC.viewModel = productViewModel
        productScreenVC.coordinator = self
        navigationController.pushViewController(productScreenVC, animated: true)
    }
    
    func goToHomeScreen() {

        let homeScreenVC = HomeScreenViewController.instantiate(storyboardName: "Main")
        
     
        let currencyService = CurrencyService.shared
        currencyService.network = NetworkService.shared
        
        let homeViewModel = HomeScreenViewModel(currencyService: currencyService, network: NetworkService.shared)
        
        homeScreenVC.viewModel = homeViewModel
        homeScreenVC.coordinator = self
        navigationController.pushViewController(homeScreenVC, animated: true)
    }
    
    func goToMainLogin(){
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let mainLogin = storyboard.instantiateViewController(withIdentifier: "generalLoginViewController") as! GeneralLoginViewController
        mainLogin.coordinator = self
        mainLogin.viewModel = GeneralLoginViewModel()
        mainLogin.navigationItem.hidesBackButton = true
        navigationController.pushViewController(mainLogin, animated: true)
    }
    
    func goToLoginWithEmail(){
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let emailLogin = storyboard.instantiateViewController(withIdentifier: "LoginWithEmailViewController") as! LoginWithEmailViewController
        emailLogin.coordinator = self
        let viewModel = LoginWithEmailViewModel()
        emailLogin.viewModel = viewModel
        emailLogin.navigationItem.hidesBackButton = true
        navigationController.pushViewController(emailLogin, animated: true)
    }
    
    func goToSignUp(){
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let signUp = storyboard.instantiateViewController(withIdentifier: "signUpViewController") as! SignUpViewController
        signUp.coordinator = self
        let viewModel = SignUpViewModel()
        signUp.viewModel = viewModel
        signUp.navigationItem.hidesBackButton = true
        navigationController.pushViewController(signUp, animated: true)
    }
    
    func goToProductInfo(product: Product){
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let productInfo = storyboard.instantiateViewController(withIdentifier: "pinfo") as! ProductInfoViewController
        productInfo.coordinator = self
        let viewModel = ProductInfoViewModel(product: product, network: NetworkService.shared , draftOrderId: "1110462660761",realmManger: RealmManager.shared)
        productInfo.viewModel = viewModel
        productInfo.navigationController?.navigationBar.isHidden = true
        navigationController.pushViewController(productInfo, animated: true)
    }
    
    func goToReviews(vc: UIViewController){
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let reviewsVC = storyboard.instantiateViewController(withIdentifier: "reviews") as! ReviewsViewController
        let viewModel = ReviewsViewModel()
        reviewsVC.viewModel = viewModel
        vc.present(reviewsVC, animated: true)
    }
    
    
    func goToWishList() {
        let storyboard = UIStoryboard(name: "MinaStoryboard", bundle: Bundle.main)
        let wishList = storyboard.instantiateViewController(withIdentifier: "WishlistViewController") as! WishlistViewController
        wishList.coordinator = self
        let viewModel = WishListViewModel(network: NetworkService.shared)
        wishList.viewModel = viewModel
        wishList.navigationItem.hidesBackButton = true
        navigationController.pushViewController(wishList, animated: true)
        
    }
    

}
