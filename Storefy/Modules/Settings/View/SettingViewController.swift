//
//  SettingViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit
import RxSwift

class SettingViewController: UIViewController, Storyboarded {
 
    @IBOutlet weak var currentCurrency: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    
    var coordinator : MainCoordinator?
    var viewModel : SettingViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        currentCurrency.text = viewModel?.getSelectedCurrency()
        checkUserLoggedIn()
    }
    
    private func checkUserLoggedIn() {
        if AuthenticationManager.shared.isUserLoggedIn() {
            btnLogout.isHidden = false
        }else{
            btnLogout.isHidden = true
        }
    }
    
    @IBAction func goToAddresses(_ sender: Any) {
        if AuthenticationManager.shared.isUserLoggedIn(){
            if checkInternetAndShowToast(vc: self) {
                coordinator?.goToAddresses()
            }
        }else{
            showAlertForNotUser(vc: self, coordinator: coordinator!)
        }
    }
    
    
    @IBAction func chengeCurrency(_ sender: Any) {
        showCurrencies()
    }
    
    
    @IBAction func goToContactUs(_ sender: Any) {
        coordinator?.goToContactUs()
    }
    
    @IBAction func goToAboutUs(_ sender: Any) {
        coordinator?.goToAboutUs()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
    private func showCurrencies(){
        let alert = UIAlertController(title: "", message: "Currency", preferredStyle: .actionSheet)
        
        let usd = UIAlertAction(title: Constant.USD, style: .default) { [weak self] action in
            self?.viewModel?.saveSelectedCurrency(currency: Constant.USD)
            self?.currentCurrency.text = Constant.USD
        }
        
        let egp = UIAlertAction(title: Constant.EGP, style: .default) {  [weak self] action in
            self?.viewModel?.saveSelectedCurrency(currency: Constant.EGP)
            self?.currentCurrency.text = Constant.EGP
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(usd)
        alert.addAction(egp)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
  
    @IBAction func logOutBtn(_ sender: Any) {
        AuthenticationManager.shared.signOut()
        coordinator?.gotoTab()
    }
    
}
