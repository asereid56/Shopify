//
//  ProductsScreenViewController.swift
//  Shopify
//
//  Created by Aser Eid on 04/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ProductsScreenViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var numOfItems: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var upperConstraintforCollectionView: NSLayoutConstraint!
    @IBOutlet weak var priceTxt: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var availableInStockTxt: UILabel!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var noInternetImg: UIImageView!
    @IBOutlet weak var btnCart: UIButton!
    private let disposeBag = DisposeBag()
    private var isSortViewHidden = true
    private var sortViewHeight : CGFloat = 0
    var viewModel : ProductScreenViewModelProtocol?
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
        
        sortView.isHidden = true
        upperConstraintforCollectionView.constant = 8
        
        productsCollectionView.collectionViewLayout = createLayout()
        
        priceSlider.rx.value.subscribe { [weak self] _ in
            self?.viewModel?.filteredTheProducts(price: self?.priceSlider.value ?? 0)
        }.disposed(by: disposeBag)
        
        selectProductToNavigate()
        setupCartButtonBinding()
        
        viewModel?.priceRange
            .subscribe(onNext: { [weak self] (min, max) in
                self?.priceSlider.minimumValue = min
                self?.priceSlider.maximumValue = max + 100
                self?.priceSlider.value = max + 100
                let maxPriceTxt = Int( max + 100 )
                self?.priceTxt.text = String(maxPriceTxt)
                
            })
            .disposed(by: disposeBag)
        
        setUpBinding()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if checkInternetAndShowToast(vc: self){
            viewModel?.fetchProducts()
            
            productsCollectionView.isHidden = false
            activityIndicator.isHidden = false
            availableInStockTxt.isHidden = false
            sortBtn.isHidden = false
            numOfItems.isHidden = false
            noInternetImg.isHidden = true
        }else {
            noInternetImg.isHidden = false
            productsCollectionView.isHidden = true
            activityIndicator.isHidden = true
            availableInStockTxt.isHidden = true
            sortBtn.isHidden = true
            numOfItems.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sortViewHeight = sortView.frame.height + 12
    }
    
    func setUpBinding(){
        
        viewModel?.data
        
            .drive(productsCollectionView.rx.items(cellIdentifier: "ProductCell", cellType: ProductCollectionXIBCell.self)) { [weak self] index, product, cell in
                cell.productCost.text = self?.viewModel?.convertPriceToCurrency(price: product.variants?.first??.price ?? "0")
                cell.productImage.kf.setImage(with: URL(string: product.image?.src ?? ""))
                cell.productName.text = product.title
                cell.layer.masksToBounds = true
                self?.brandName.text = product.vendor
            }
            .disposed(by: disposeBag)
        
        
        viewModel?.productsCount
            .map { "\($0) items"}
            .bind(to: numOfItems.rx.text)
            .disposed(by: disposeBag)
        
        priceSlider.rx.value
            .map { Int($0) }
            .map { "\($0)" }
            .bind(to: priceTxt.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.isLoading
            .map{ !$0 }
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.dataFetchCompleted
            .subscribe(onNext: { [weak self ] in
                self?.activityIndicator.isHidden = true
            })
            .disposed(by: disposeBag)
        
    }
    
    func selectProductToNavigate(){
        productsCollectionView.rx.modelSelected(Product.self)
            .subscribe(onNext: { [weak self] product in
                guard let self = self else { return }
                self.coordinator?.goToProductInfo(product: product)
            })
            .disposed(by: disposeBag)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @IBAction func sliderDidChanged(_ sender: UISlider) {
        let intValue = Int(sender.value)
        priceTxt.text = String(intValue)
    }
    
    @IBAction func filterBtn(_ sender: Any) {
        isSortViewHidden = !isSortViewHidden
        UIView.animate(withDuration: 0.8) {
            self.sortView.isHidden = self.isSortViewHidden
            self.upperConstraintforCollectionView.constant = self.isSortViewHidden ? 8 : self.sortViewHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupCartButtonBinding() {
        btnCart.rx.tap
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.handleCartButtonTap()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleCartButtonTap() {
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
    
    
    @IBAction func favBtn(_ sender: Any) {
        if AuthenticationManager.shared.isUserLoggedIn() {
            coordinator?.goToWishList()
        }else {
            showAlertForNotUser(vc: self, coordinator: coordinator!)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
}

