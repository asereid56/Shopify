//
//  ProfileViewController.swift
//  Shopify
//
//  Created by Mina on 16/06/2024.
//

import UIKit

class ProfileViewController: UIViewController {
    var viewModel: ProfileViewModel?
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var wishlistView: UIView!
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var wishItem1: UIView!
    @IBOutlet weak var wishItem2: UIView!
    @IBOutlet weak var signedInUserView: UIView!
    @IBOutlet weak var noUserView: UIView!
    @IBOutlet weak var secondItemPrice: UILabel!
    @IBOutlet weak var secondItemLabel: UILabel!
    @IBOutlet weak var firstItemPrice: UILabel!
    @IBOutlet weak var firstItemLabel: UILabel!
    @IBOutlet weak var firstItemImage: UIImageView!
    @IBOutlet weak var secondItemImage: UIImageView!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var myOrdersLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 12
    }
    override func viewWillAppear(_ animated: Bool) {
        if !AuthenticationManager.shared.isUserLoggedIn() {
            noUserView.isHidden = false
            signedInUserView.isHidden = true
        }
        else {
            noUserView.isHidden = true
            signedInUserView.isHidden = false
            viewModel?.getOrders()
            viewModel?.getWishListItems()
            let firstName = UserDefaultsManager.shared.getFirstNameFromUserDefaults() ?? ""
            let lastName = UserDefaultsManager.shared.getLastNameFromUserDefaults() ?? ""
            let fullName = firstName + " " + lastName
            profileName.text = fullName
            
            _ = viewModel?.data.drive(onNext: { [weak self] orders in
                if !orders.isEmpty {
                    self?.ordersView.isHidden = false
                    self?.totalAmount.text = orders.first?.currentTotalPrice
                    self?.createdAt.text = orders.first?.createdAt
                    self?.address.text = (orders.first?.province ?? "") + ", " + (orders.first?.province ?? "")
                }
                else {
                    self?.ordersView.isHidden = true
//                    if let myOrdersLabel = self?.profileImage, let wishlistView = self?.wishlistView {
//                        wishlistView.topAnchor.constraint(equalTo: myOrdersLabel.bottomAnchor, constant: 12).isActive = true
//                    }
//                    self?.view.layoutIfNeeded()
                }
                
            })
            
            _ = viewModel?.wishlistData.drive(onNext: { [weak self] wishlist in
                print("WISHLIST COUNT: \(wishlist.count)")
                
                if wishlist.count > 1 {
                    self?.wishItem1.isHidden = false
                    self?.firstItemLabel.text = wishlist[1].title
                    self?.firstItemPrice.text = wishlist[1].price
                    let components = wishlist[1].sku?.components(separatedBy: " ")
                    self?.firstItemImage.kf.setImage(with: URL(string: components?[0] ?? ""))
                }
                else {
                    self?.wishItem1.isHidden = true
                }
                if wishlist.count > 2 {
                    self?.wishItem2.isHidden = false
                    self?.secondItemLabel.text = wishlist[2].title
                    self?.secondItemPrice.text = wishlist[2].price
                    let components = wishlist[2].sku?.components(separatedBy: " ")
                    self?.secondItemImage.kf.setImage(with: URL(string: components?[0] ?? ""))
                }
                else {
                    self?.wishItem2.isHidden = true
                }
            })
        }
    }
    @IBAction func showAllOrders(_ sender: Any) {
        //coordinator.goToOrders
    }
    @IBAction func showWishlist(_ sender: Any) {
        coordinator?.goToWishList()
    }
    @IBAction func goToSettings(_ sender: Any) {
        coordinator?.goToSettings()
    }
    
    @IBAction func goToCart(_ sender: Any) {
        coordinator?.goToShoppingCart()
    }
    @IBAction func logIn(_ sender: Any) {
        coordinator?.goToMainLogin()
    }
    @IBAction func signUp(_ sender: Any) {
        coordinator?.goToSignUp()
    }
}
