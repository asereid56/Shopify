//
//  ProfileViewController.swift
//  Shopify
//
//  Created by Mina on 16/06/2024.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate , Storyboarded {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showOrdersChevron: UIImageView!
    @IBOutlet weak var showOrders: UIButton!
    @IBOutlet weak var emptyWishlitView: UIView!
    @IBOutlet weak var noOrdersView: UIView!
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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var showWishlistChevron: UIImageView!
    @IBOutlet weak var showWishlist: UIButton!
    @IBOutlet weak var editImage: UILabel!
    
    var viewModel: ProfileViewModel?
    var coordinator: MainCoordinator?
    var tapGesture: UITapGestureRecognizer!
    var tapGesture1: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if checkInternetAndShowToast(vc: self) {
            updateImage()
        }
        else {
            self.profileImageIndicator.isHidden = true
        }
        if !AuthenticationManager.shared.isUserLoggedIn() {
            noUserView.isHidden = false
            signedInUserView.isHidden = true
        }
        else {
            setupUserInfo()
            if !checkInternetAndShowToast(vc: self) {
                emptyWishlitView.isHidden = false
                noOrdersView.isHidden = false
            } else {
                setupOrders()
                setupWishlist()
            }
        }
        
    }
    
    
    @IBAction func showAllOrders(_ sender: Any) {
        viewModel?.fetchOrders(completion: { orders in
            self.coordinator?.gotoOrdersScreen(orders: orders)
        })
    }
    
    @IBAction func showWishlist(_ sender: Any) {
        coordinator?.goToWishList()
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        coordinator?.goToSettings()
    }
    
    @IBAction func goToCart(_ sender: Any) {
        print(AuthenticationManager.shared.isUserLoggedIn())
        if AuthenticationManager.shared.isUserLoggedIn() {
            if isInternetAvailable() {
                isEmailVerified(vc: self) { [weak self] isVerified in
                    if isVerified {
                        self?.coordinator?.goToShoppingCart()
                    }
                }
            }
            else {
                if viewModel?.isVerified() ?? false{
                    coordinator?.goToShoppingCart()
                }
                else {
                    let action1 = UIAlertAction(title: "Resend email", style: .default) { _ in
                        AuthenticationManager.shared.resendEmailVerificaiton() {
                            _ = showAlert(message: "Email verification sent", vc: self)
                        }
                    }
                    
                    let action2 = UIAlertAction(title: "Dismiss", style: .cancel)
                    _ = showAlert(title: "Email Verification Required", message: "You must verify your email in order to proceed", vc: self, actions: [action2, action1], style: .alert, selfDismiss: false, completion: nil)
                }
            }
            
        }else {
            showAlertForNotUser(vc: self, coordinator: coordinator!)
        }
    }
    
    @IBAction func logIn(_ sender: Any) {
        coordinator?.goToLogin()
    }
    
    @IBAction func signUp(_ sender: Any) {
        coordinator?.goToSignUp()
    }
    
    @objc func changeImage(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if checkInternetAndShowToast(vc: self) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var alert = UIAlertController()
        loadingIndicator.isHidden = false
        let selected = info[.originalImage] as! UIImage
        self.profileImage.image = selected
        let data = selected.jpegData(compressionQuality: 0.1)
        picker.dismiss(animated: true) {
            alert = showAlert(message: "please wait, your image is being updated..", vc: self, selfDismiss: false)!
        }
        
        viewModel?.saveImage(data: data ?? Data()) { result in
            alert.dismiss(animated: true)
            self.loadingIndicator.isHidden = true
            if result {
                _ = showAlert(message: "image updated successfully", vc: self)
            }
            else {
                _ = showAlert(message: "Couldn't update image, try again", vc: self)
            }
        }
        
    }
    
    func updateImage() {
        viewModel?.updateImage(completion: { [weak self] data in
            guard let self else { return }
            DispatchQueue.main.async {
                print("HEERREE")
                if data.isEmpty {
                    self.profileImage.image = UIImage(named: "placeholder")
                } else {
                    self.profileImage.image = UIImage(data: data)
                }
                self.profileImageIndicator.isHidden = true
            }
        })
    }
    
    func setupOrders() {
        viewModel?.getOrders()
        _ = viewModel?.data.drive(onNext: { [weak self] orders in
            guard let self else { return }
            if !orders.isEmpty {
                
                noOrdersView.isHidden = true
                showOrders.isHidden = false
                showOrdersChevron.isHidden = false
                totalAmount.text = CurrencyService.calculatePriceAccordingToCurrency(price: String(orders.last?.currentTotalPrice ?? "0"))
                if let createdAtString = orders.last?.createdAt {
                    let endIndex = createdAtString.index(createdAtString.startIndex, offsetBy: 10)
                    createdAt.text = String(createdAtString[..<endIndex])
                }
                address.text = (orders.last?.shippingAddress?.city ?? "") + ", " + (orders.last?.shippingAddress?.country ?? "")
                self.phoneNumber.text = orders.last?.shippingAddress?.phone
            }
            else {
                noOrdersView.isHidden = false
                showOrders.isHidden = true
                showOrdersChevron.isHidden = true
            }
            
        })
    }
    
    func setupWishlist() {
        viewModel?.getWishListItems()
        _ = viewModel?.wishlistData.drive(onNext: { [weak self] wishlist in
            print("WISHLIST COUNT: \(wishlist.count)")
            
            if wishlist.count > 1 {
                self?.emptyWishlitView.isHidden = true
                self?.showWishlist.isHidden = false
                self?.showWishlistChevron.isHidden = false
                self?.firstItemLabel.text = wishlist[1].title
                self?.firstItemPrice.text =  CurrencyService.calculatePriceAccordingToCurrency(price: String(wishlist[1].price ?? "0"))
                let components = wishlist[1].sku?.components(separatedBy: " ")
                self?.firstItemImage.kf.setImage(with: URL(string: components?[0] ?? ""))
            }
            else {
                self?.emptyWishlitView.isHidden = false
                self?.showWishlist.isHidden = true
                self?.showWishlistChevron.isHidden = true
            }
            if wishlist.count > 2 {
                self?.secondItemImage.isHidden = false
                self?.secondItemLabel.isHidden = false
                self?.secondItemPrice.isHidden = false
                self?.secondItemLabel.text = wishlist[2].title
                self?.secondItemPrice.text = CurrencyService.calculatePriceAccordingToCurrency(price: String(wishlist[2].price ?? "0"))
                let components = wishlist[2].sku?.components(separatedBy: " ")
                self?.secondItemImage.kf.setImage(with: URL(string: components?[0] ?? ""))
            }
            else {
                self?.secondItemImage.isHidden = true
                self?.secondItemLabel.isHidden = true
                self?.secondItemPrice.isHidden = true
            }
        })
    }
    
    func setupUserInfo() {
        let firstName = UserDefaultsManager.shared.getFirstNameFromUserDefaults() ?? ""
        let lastName = UserDefaultsManager.shared.getLastNameFromUserDefaults() ?? ""
        let fullName = firstName + " " + lastName
        profileName.text = fullName
        noUserView.isHidden = true
        signedInUserView.isHidden = false
    }
    
    func setupProfileImage() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        editImage.addGestureRecognizer(tapGesture)
        profileImage.addGestureRecognizer(tapGesture1)
        profileImage.layer.cornerRadius = profileImage.bounds.width/2
    }
}
