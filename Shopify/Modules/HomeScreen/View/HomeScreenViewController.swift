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
    
    var viewModel : HomeScreenViewModelProtocol?
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var adsArray : [AdsItems] = []
    
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        let nib = UINib(nibName: "BrandsCollectionXIBCell", bundle: nil)
        brandsCollection.register(nib, forCellWithReuseIdentifier: "brandCell")
        
        adsArray = [
            AdsItems(image: "addidasAds"),
            AdsItems(image: "pumaAds"),
            AdsItems(image: "nikaAds"),
            AdsItems(image: "reebokAds"),
            AdsItems(image: "filaAds")
        ]
        
        configurePageController()
        startAutoScrollingToAdsCollection()
        
        brandsCollection.collectionViewLayout = createBrandsLayout()
        adsCollection.collectionViewLayout = createAdsLayout()
        
        selectBrandToNavigate()
        viewModel?.fetchCurrencyRate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adsCollection.delegate = nil
        adsCollection.dataSource = nil
        brandsCollection.delegate = nil
        brandsCollection.dataSource = nil
        viewModel?.fetchBranchs()
        setUpBrandsBinding()
        setUpAdsBinding()
    }
    
    func setUpAdsBinding() {
        Observable.just(adsArray)
            .bind(to: adsCollection.rx.items(cellIdentifier: "adsCell", cellType: AdsCollectionCell.self)) { index, adsItem, cell in
                
                cell.adsImage.image = UIImage(named: adsItem.image)
                cell.layer.cornerRadius = 15
                cell.layer.masksToBounds = true
            }
            .disposed(by: disposeBag)
        
    }
    
    func setUpBrandsBinding() {
        viewModel?.data.drive(brandsCollection.rx.items(cellIdentifier: "brandCell", cellType: BrandsCollectionXIBCell.self)){ index , brand , cell in
        
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            cell.brandImage.kf.setImage(with: URL(string: brand.image.src ?? ""))
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            
        }
        .disposed(by: disposeBag)
        
    }
    
    func selectBrandToNavigate(){
        brandsCollection.rx.modelSelected(SmartCollection.self)
            .subscribe(onNext: { [weak self] brand in
                guard let self = self else { return }
                self.coordinator?.gotoProductsScreen(with: String(brand.id))
            })
            .disposed(by: disposeBag)
    }
    
    func configurePageController(){
        self.pageController.numberOfPages = self.adsArray.count
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
        
        let nextItem = (currentIndexPath.item + 1) % adsArray.count
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
    
    @IBAction func cartBtn(_ sender: Any) {
        
        coordinator?.goToShoppingCart()
    }
    
    @IBAction func wishListBtn(_ sender: Any) {
        coordinator?.goToWishList()
    }
    
}
