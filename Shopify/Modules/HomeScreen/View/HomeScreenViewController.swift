//
//  ViewController.swift
//  Shopify
//
//  Created by Aser Eid on 02/06/2024.
//

import UIKit
import RxSwift
import Kingfisher
import RxCocoa

class HomeScreenViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var adsCollection: UICollectionView!
    @IBOutlet weak var brandsCollection: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noInternetImage: UIImageView!
    @IBOutlet weak var chooseBrandTxt: UILabel!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var btnCart: UIButton!
    var viewModel : HomeScreenViewModelProtocol?
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var homeScreenSource : String?
    var timer : Timer?
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        let nib = UINib(nibName: "BrandsCollectionXIBCell", bundle: nil)
        brandsCollection.register(nib, forCellWithReuseIdentifier: "brandCell")
        configurePageController()
        startAutoScrollingToAdsCollection()
        
        brandsCollection.collectionViewLayout = createBrandsLayout()
        adsCollection.collectionViewLayout = createAdsLayout()
        
        selectBrandToNavigate()
        viewModel?.fetchCurrencyRate()
        if homeScreenSource == "PAYMENT" {showErrorAlert()}
        
        // if checkInternetAndShowToast(vc: self) {
        setUpBrandsBinding()
        setUpAdsBinding()
        setupSearchBar()
        setupCartButtonBinding()
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(AuthenticationManager.shared.isUserLoggedIn())
        checkonUserDefaultsValues()
        //  setupSearchBar()
        
        
        if checkInternetAndShowToast(vc: self) {
            noInternetImage.isHidden = true
            chooseBrandTxt.isHidden = false
            activityIndicator.isHidden = false
            adsCollection.isHidden = false
            brandsCollection.isHidden = false
            searchBar.isHidden = false
            viewLoading.isHidden = false
            viewModel?.fetchBranchs()
            viewModel?.fetchCoupons()
            
        }else {
            adsCollection.isHidden = true
            brandsCollection.isHidden = true
            chooseBrandTxt.isHidden = true
            activityIndicator.isHidden = true
            noInternetImage.isHidden = false
            searchBar.isHidden = true
            viewLoading.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstTime {
            if homeScreenSource == "SignUp"{
                _ = showAlert(message: "Welcome \(viewModel?.getUserName() ?? "")", vc: self ) {
                    let action1 = UIAlertAction(title: "Dismiss", style: .cancel)
                    _ = showAlert(title: "Email Verification Required", message: "We've sent you an email with the link to verify your email", vc: self , actions: [action1], style: .alert, selfDismiss: false)
                }
            }
            isFirstTime = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Failed!", message: "Something went wrong while placing order", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func setUpAdsBinding() {
        viewModel?.adsArray
            .bind(to: adsCollection.rx.items(cellIdentifier: "adsCell", cellType: AdsCollectionCell.self)) { index, adsItem, cell in
                cell.adsImage.image = UIImage(named: adsItem.image)
                cell.couponImage.image = UIImage(named: (self.viewModel?.getCoupons()[index].title)!)
                cell.layer.cornerRadius = 15
                cell.layer.masksToBounds = true
                cell.circularView.layer.cornerRadius = cell.circularView.frame.size.width / 2
                cell.circularView.clipsToBounds = true
            }
            .disposed(by: disposeBag)
        
        adsCollection.rx.modelSelected(AdsItems.self)
            .subscribe(onNext: { [weak self] adsItem in
                guard let indexPath = self?.adsCollection.indexPathsForSelectedItems?.first else {
                    return
                }
                isEmailVerified(vc: self!) { [weak self] isVerified in
                    if isVerified {
                        UIPasteboard.general.string = self?.viewModel?.getCoupons()[indexPath.row].title.replacingOccurrences(of: "%", with: "%25")
                        let alert = UIAlertController(title: nil, message: "Congratulations! Your discount code has been copied to the clipboard.", preferredStyle: .actionSheet)
                        self?.present(alert, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            alert.dismiss(animated: true)
                        }
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
    
    func setUpBrandsBinding() {
        viewModel?.data.drive(brandsCollection.rx.items(cellIdentifier: "brandCell", cellType: BrandsCollectionXIBCell.self)){ index , brand , cell in
            
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            cell.brandImage.kf.setImage(with: URL(string: brand.image.src))
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            
        }
        .disposed(by: disposeBag)
        
        viewModel?.isLoading
            .map { !$0 }
            .do(onDispose: {
                self.viewLoading.isHidden = false
            })
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.dataFetchCompleted
            .subscribe(onNext: { [weak self] in
                self?.activityIndicator.isHidden = true
                self?.viewLoading.isHidden = true
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func selectBrandToNavigate(){
        print("selecting item to navigate from home")
        brandsCollection.rx.modelSelected(SmartCollection.self)
            .subscribe(onNext: { [weak self] brand in
                guard let self = self else { return }
                self.coordinator?.gotoProductsScreen(with: String(brand.id))
                
            })
            .disposed(by: disposeBag)
    }
    
    func configurePageController(){
        self.pageController.numberOfPages = self.viewModel?.getAdsArrCount() ?? 0
        self.pageController.currentPage = 0
        self.pageController.layer.cornerRadius = 12
        self.pageController.addTarget(self, action: #selector(pageControllerTapped), for: .valueChanged)
    }
    
    @objc func pageControllerTapped(_ sender : UIPageControl){
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        adsCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func startAutoScrollingToAdsCollection(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    
    @objc func scrollToNextItem(){
        let items = adsCollection.indexPathsForVisibleItems.sorted()
        guard let currentIndexPath = items.first else { return }
        
        let nextItem = (currentIndexPath.item + 1) % (viewModel?.getAdsArrCount() ?? 0)
        let nextIndexPath = IndexPath(item: nextItem, section: 0)
        
        adsCollection.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        
        pageController.currentPage = nextItem
    }
    
    func createAdsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
    func createBrandsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0 / 2.3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func setupCartButtonBinding() {
        btnCart.rx.tap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
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
    
    @IBAction func cartBtn(_ sender: Any) {
        //        print(AuthenticationManager.shared.isUserLoggedIn())
        //        if AuthenticationManager.shared.isUserLoggedIn() {
        //            if isInternetAvailable() {
        //                isEmailVerified(vc: self) { [weak self] isVerified in
        //                    if isVerified {
        //                        self?.coordinator?.goToShoppingCart()
        //                    }
        //                }
        //            }
        //            else {
        //                if viewModel?.isVerified() ?? false{
        //                    coordinator?.goToShoppingCart()
        //                }
        //                else {
        //                    let action1 = UIAlertAction(title: "Resend email", style: .default) { _ in
        //                        AuthenticationManager.shared.resendEmailVerificaiton() {
        //                            _ = showAlert(message: "Email verification sent", vc: self)
        //                        }
        //                    }
        //
        //                    let action2 = UIAlertAction(title: "Dismiss", style: .cancel)
        //                    _ = showAlert(title: "Email Verification Required", message: "You must verify your email in order to proceed", vc: self, actions: [action2, action1], style: .alert, selfDismiss: false, completion: nil)
        //                }
        //            }
        //
        //        }else {
        //            showAlertForNotUser(vc: self, coordinator: coordinator!)
        //        }
    }
    
    @IBAction func wishListBtn(_ sender: Any) {
        if AuthenticationManager.shared.isUserLoggedIn() {
            coordinator?.goToWishList()
        }else {
            showAlertForNotUser(vc: self, coordinator: coordinator!)
        }
    }
    
    func setupSearchBar() {
        if checkInternetAndShowToast(vc: self) {
            searchBar.rx.text.orEmpty
                .do(onNext: { [weak self] searchText in
                    if searchText.isEmpty {
                        self?.searchBar.resignFirstResponder()
                    }
                })
                .bind(to: viewModel?.searchTextSubject ?? PublishSubject<String>())
                .disposed(by: disposeBag)
        }
    }
    
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            searchBar.endEditing(true)
        }
    }
}
