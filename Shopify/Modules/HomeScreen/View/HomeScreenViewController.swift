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

class HomeScreenViewController: UIViewController , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var adsCollection: UICollectionView!
    @IBOutlet weak var brandsCollection: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    var viewModel : HomeScreenViewModelProtocol?
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var adsArray : [AdsItems] = []
    var brandsArray: [SmartCollection] = []
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false);
        let nib = UINib(nibName: "BrandsCollectionXIBCell", bundle: nil)
        brandsCollection.register(nib, forCellWithReuseIdentifier: "brandCell")
        
        adsArray = [
            AdsItems(image: "addidasAds"),
            AdsItems(image: "pumaAds"),
            AdsItems(image: "nikaAds"),
            AdsItems(image: "reebokAds"),
            AdsItems(image: "filaAds")
        ]
        
        adsCollection.layer.cornerRadius = 15
        configurePageController()
        startAutoScrollingToAdsCollection()
        brandsCollection.delegate = self
        brandsCollection.dataSource = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.fetchBranchs()
        setUpBinding()
    }
    
    func setUpBinding() {
        viewModel?.data.drive(brandsCollection.rx.items(cellIdentifier: "brandCell", cellType: BrandsCollectionXIBCell.self)){ [weak self] index , brand , cell in
            
            guard let self = self else { return }
            self.brandsArray.append(brand)
            
            cell.brandImage.kf.setImage(with: URL(string: brand.image.src))
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
      
        }
        .disposed(by: disposeBag)
        
        brandsCollection.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let selectedBrand = self.brandsArray[indexPath.row]
                self.coordinator?.gotoProductsScreen(with: String(selectedBrand.id))
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == brandsCollection {
            let width = (collectionView.frame.width - 15) / 3
            let height = (collectionView.frame.height - 10) / 3
            return CGSize(width: width, height: height)
        }else {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
        }
        
    }
    
    @IBAction func cartBtn(_ sender: Any) {
        
    }
}

extension HomeScreenViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == adsCollection {
            return adsArray.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == adsCollection {
            let selectedAds = adsArray[indexPath.row]
            let cell = adsCollection.dequeueReusableCell(withReuseIdentifier: "adsCell", for: indexPath) as! AdsCollectionCell
            cell.adsImage.image = UIImage(named: selectedAds.image)
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            return cell
        }else {
            //            let selectedBrand = brandsArray[indexPath.row]
            //            let cell = brandsCollection.dequeueReusableCell(withReuseIdentifier: "brandCell", for: indexPath) as! BrandsCollectionCell
            //            cell.brandImage.image = UIImage(named: selectedBrand.image)
            //
            //            cell.layer.borderColor = UIColor.black.cgColor
            //            cell.layer.borderWidth = 1.0
            //            cell.layer.cornerRadius = 15
            //            cell.layer.masksToBounds = true
            //            return cell
            fatalError("brands will appear in binding")
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
}
