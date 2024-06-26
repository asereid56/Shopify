//
//  CategoryScreenViewController.swift
//  Shopify
//
//  Created by Aser Eid on 02/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class CategoryScreenViewController: UIViewController , Storyboarded{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var noInternetImg: UIImageView!
    
    @IBOutlet weak var btnCart: UIButton!
    private let disposeBag = DisposeBag()
    private var lastCategory: APIEndpoint = .CategoryWomen
    private var lastCategoryTitle = "Women's"
    var coordinator : MainCoordinator?
    var viewModel : CategoryScreenViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        categoryCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
        
        categoryCollectionView.collectionViewLayout = createLayout()
        
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.filterData(selectedSegmentIndex: self?.segmentedControl.selectedSegmentIndex ?? 0)
            })
            .disposed(by: disposeBag)
        
        selectProductToNavigate()
        setUpBinding()
        setupCartButtonBinding()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSearchBar()
        categoryBtn.titleLabel?.text = lastCategoryTitle
        
        if checkInternetAndShowToast(vc: self){
            viewModel?.fetchData(with: lastCategory.rawValue)
            categoryCollectionView.isHidden = false
            segmentedControl.isHidden = false
            categoryBtn.isHidden = false
            emptyImg.isHidden = true
            activityIndicator.isHidden = false
            noInternetImg.isHidden = true
            searchBar.isHidden = false
        }else {
            noInternetImg.isHidden = false
            categoryCollectionView.isHidden = true
            segmentedControl.isHidden = true
            categoryBtn.isHidden = true
            emptyImg.isHidden = true
            activityIndicator.isHidden = true
            searchBar.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
        }
    }
    
    private func setUpBinding(){
        viewModel?.data.map({ products in
            return products.filter { product in
                switch self.segmentedControl.selectedSegmentIndex {
                    
                case 1:
                    return product.productType == "TROUSERS"
                case 2:
                    return  product.productType == "T-SHIRTS"
                case 3:
                    return product.productType == "SHOES"
                case 4:
                    return product.productType == "ACCESSORIES"
                default:
                    return true
                }
            }
        }).drive(categoryCollectionView.rx.items(cellIdentifier: "ProductCell", cellType: ProductCollectionXIBCell.self)){ index , product , cell in
            
            cell.productCost.text = CurrencyService.calculatePriceAccordingToCurrency(price: String(product.variants?.first??.price ?? "0"))
            cell.productImage.kf.setImage(with: URL(string: product.image?.src ?? ""))
            cell.productName.text = product.title
            cell.layer.masksToBounds = true
            
        }.disposed(by: disposeBag)
        
        viewModel?.isLoading
            .map{ !$0 }
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.isEmpty
            .map { !$0 }
            .bind(to: emptyImg.rx.isHidden)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel!.isLoading, viewModel!.isEmpty)
            .subscribe(onNext: { [weak self] isLoading, isEmpty in
                self?.activityIndicator.isHidden = !isLoading
                self?.emptyImg.isHidden  = isLoading || !isEmpty
                self?.categoryCollectionView.isHidden = isLoading || isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    func selectProductToNavigate(){
        if checkInternetAndShowToast(vc: self){
            categoryCollectionView.rx.modelSelected(Product.self)
                .subscribe(onNext: { [weak self] product in
                    guard let self = self else { return }
                    self.coordinator?.goToProductInfo(product: product)
                })
                .disposed(by: disposeBag)
        }
    }
    
    @IBAction func favBtn(_ sender: Any) {
        if AuthenticationManager.shared.isUserLoggedIn() {
            coordinator?.goToWishList()
        }else {
            showAlertForNotUser(vc: self, coordinator: coordinator!)
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
    
    
    @IBAction func categoryBtn(_ sender: Any) {
        self.categoryBtn.titleLabel?.text = lastCategoryTitle
        
        let alert = UIAlertController(title: "", message: "FILTER BY CATEGORY", preferredStyle: .actionSheet)
        
        let all = UIAlertAction(title: "All", style: .default) { action in
            self.lastCategoryTitle = " All"
            self.updateCategoryButton(title: self.lastCategoryTitle, endpoint: .CategoryAll)
        }
        
        let men = UIAlertAction(title: "Men's", style: .default) { action in
            self.lastCategoryTitle = " Men's"
            self.updateCategoryButton(title: self.lastCategoryTitle, endpoint: .CategoryMen)
        }
        let women = UIAlertAction(title: "Women's", style: .default) { action in
            self.lastCategoryTitle = "Women's"
            self.updateCategoryButton(title: self.lastCategoryTitle, endpoint: .CategoryWomen)
        }
        let kid = UIAlertAction(title: "Kids", style: .default) { action in
            self.lastCategoryTitle = " Kids"
            self.updateCategoryButton(title: self.lastCategoryTitle, endpoint: .CategoryKids)
        }
        let sale = UIAlertAction(title: "SALE", style: .default) { action in
            self.lastCategoryTitle = " SALE"
            self.updateCategoryButton(title: self.lastCategoryTitle, endpoint: .CategorySale)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.categoryBtn.titleLabel?.text =  self.lastCategoryTitle
        }
        
        alert.addAction(all)
        alert.addAction(men)
        alert.addAction(women)
        alert.addAction(kid)
        alert.addAction(sale)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func updateCategoryButton(title: String, endpoint: APIEndpoint) {
        self.categoryBtn.titleLabel?.text = title
        self.lastCategory = endpoint
        self.viewModel?.fetchData(with: endpoint.rawValue)
    }
    
    private func createLayout() -> UICollectionViewLayout{
        
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
    func setupSearchBar() {
        if checkInternetAndShowToast(vc: self) {
            searchBar.rx.text.orEmpty
                .bind(to: viewModel?.searchTextSubject ?? PublishSubject<String>())
                .disposed(by: disposeBag)
        }
    }
    
    
}

