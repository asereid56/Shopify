//
//  ProductInfoViewController.swift
//  Shopify
//
//  Created by Mina on 01/06/2024.
//

import UIKit
import Cosmos
import RxSwift
import Firebase

class ProductInfoViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var wishlistButton: UIButton!
    var coordinator: MainCoordinator?
    var viewModel: ProductInfoViewModel?
    let disposeBag = DisposeBag()
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var descriptionTxt: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var imgs: [ProductImage?]?
    override func viewDidLoad() {
        print("USER STATUS: \(AuthenticationManager.shared.isUserLoggedIn())")
        checkonUserDefaultsValues()
        super.viewDidLoad()
        if AuthenticationManager.shared.isUserLoggedIn() {
            checkWishlistStatus()
        }
        addToCart()
        pageControl.layer.cornerRadius = 12
        print(viewModel?.product?.id ?? "")
        imgs = viewModel?.product?.images
        configureNib()
        
        if viewModel?.makeNetworkCall == true {
            viewModel?.getProduct() { [weak self] in
                guard let self = self else { return }
                self.setProductInfo()
                self.setupScrollView()
                self.setupDropDownButton(self.colorButton, options: self.viewModel?.product?.options?[1]?.values ?? [])
                self.setupDropDownButton(self.sizeButton, options: self.viewModel?.product?.options?[0]?.values ?? [])
            }
        } else {
            setProductInfo()
            setupDropDownButton(sizeButton, options: viewModel?.product?.options?[0]?.values ?? [])
            setupDropDownButton(colorButton, options: viewModel?.product?.options?[1]?.values ?? [])
        }
        
        bindViewModel()
        configureScrollView()
        setupScrollView()
        bindReviews()
        viewModel?.getReviews()
    }
    
    private func bindViewModel() {
        viewModel?.isLoading
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.isLoading
            .map { !$0 }
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindReviews() {
        viewModel?.reviewsData.bind(to: reviewsTableView.rx.items(cellIdentifier: "reviewCell", cellType: ReviewTableViewCell.self)) { index, item, cell in
            cell.configure(item: item)
        }.disposed(by: disposeBag)
    }
    
    private func checkWishlistStatus() {
        if checkInternetAndShowToast(vc: self) {
            viewModel?.isProductInWishlist { [weak self] yes in
                let imageName = yes ? "heart.fill" : "heart"
                self?.wishlistButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
        }
    }
    
    private func cleanup() {
        reviewsTableView.dataSource = nil
        reviewsTableView.delegate = nil
        scrollView.delegate = nil
    }
    
    func setupDropDownButton(_ button: UIButton, options: [String]) {
        let menuClosure = { (action: UIAction) in
            self.update(number: action.title)
        }
        var children = [UIMenuElement]()
        for option in options {
            children.append(UIAction(title: option, state: .on, handler: menuClosure))
        }
        button.menu = UIMenu(children: children)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
    }
    
    func update(number: String) {
        print("\(number) selected")
    }
    
    func getVariantTitle() -> String {
        sizeButton.currentTitle! + " / " + colorButton.currentTitle!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(page)
    }
    
    
    private func addToCart() {
        viewModel?.addToCart.subscribe(onNext:  {isAdded in
            if isAdded {
                _ = showToast(message: "Product added to shopping cart", vc: self)
            } else {
                _ =  showToast(message: "Product already exists in shopping cart", vc: self)
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func viewAll(_ sender: Any) {
        coordinator?.goToReviews(vc: self)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if checkInternetAndShowToast(vc: self){
            if AuthenticationManager.shared.isUserLoggedIn() {
                isEmailVerified(vc: self) { [weak self] isVerified in
                    if isVerified {
                       let variant = self?.viewModel?.getSelectedVariant(title: (self?.getVariantTitle())!)
                        self?.viewModel?.fetchDraftOrder(variant: variant!)
                    }
                }
              
            }else{
                showAlertForNotUser(vc: self, coordinator: coordinator!)
            }
        }
    }
    
    @IBAction func addToWishList(_ sender: Any) {
        if !AuthenticationManager.shared.isUserLoggedIn() {
            
            let action1 = UIAlertAction(title: "Cancel", style: .cancel)
            let action2 = UIAlertAction(title: "Sign in", style: .default) { _ in
                self.coordinator?.goToLogin()
            }
            _ = showToast(message: "You must be signed in to add to your wishlist", vc: self, actions: [action1, action2], style: .alert, selfDismiss: false)
        } else {
            addToWishlist()
        }
    }
    func addToWishlist() {
        if checkInternetAndShowToast(vc: self) {
            viewModel?.isProductInWishlist { yes in
                if yes {
                    let action1 = UIAlertAction(title: "Cancel", style: .default)
                    let action2 = UIAlertAction(title: "Delete", style: .destructive) { _ in
                        self.viewModel?.removeProduct {
                            self.wishlistButton.setImage(UIImage(systemName: "heart"), for: .normal)
                            _ = showToast(message: "Product removed from wishlist", vc: self)
                        }
                    }
                    _ = showToast(message: "Are you sure you want to remove this product from your wishlist?", vc: self, actions: [action1, action2], style: .alert, selfDismiss: false)
                } else {
                    self.viewModel?.addToWishList(product: self.viewModel?.product, vc: self) { success in
                        if success {
                            _ = showToast(message: "Product added to wishlist", vc: self)
                            self.wishlistButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        } else {
                            _ = showToast(message: "Failed to add to wishlist", vc: self)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        cleanup()
        coordinator?.goBack()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewCell")
    }
    
    func configureScrollView() {
        reviewsTableView.rowHeight = 140
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        pageControl.numberOfPages = imgs?.count ?? 0
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }
    
    func setupScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        pageControl.layer.cornerRadius = 12
        let scrollViewWidth = scrollView.frame.size.width
        let scrollViewHeight = scrollView.frame.size.height
        
        for i in 0..<(imgs?.count ?? 0) {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.kf.setImage(with: URL(string: imgs?[i]?.src ?? ""))
            let xPosition = CGFloat(i) * scrollViewWidth
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(imgs?.count ?? 0), height: scrollViewHeight)
    }
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let scrollViewWidth = scrollView.frame.size.width
        let offset = CGPoint(x: CGFloat(currentPage) * scrollViewWidth, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func setProductInfo() {
        self.imgs = self.viewModel?.product?.images
        productName.text = viewModel?.product?.title
        productPrice.text =  CurrencyService.calculatePriceAccordingToCurrency(price: String(viewModel?.product?.variants?.first??.price ?? "0"))
        descriptionTxt.text = viewModel?.product?.bodyHTML
    }
}

