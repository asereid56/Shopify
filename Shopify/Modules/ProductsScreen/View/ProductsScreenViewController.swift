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

class ProductsScreenViewController: UIViewController {
    
    @IBOutlet weak var numOfItems: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var upperConstraintforCollectionView: NSLayoutConstraint!
    @IBOutlet weak var priceTxt: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        productsCollectionView.delegate = nil
        productsCollectionView.dataSource = nil
        
        viewModel?.fetchProducts()
        setUpBinding()
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sortViewHeight = sortView.frame.height + 12
    }
    
    func setUpBinding(){
        
        viewModel?.data
//               .compactMap { [weak self] products -> [Product]? in
//                   let prices = products.compactMap { product in
//                       Float(product.variants?.first??.price ?? "0")
//                   }
//                   self?.priceSlider.maximumValue = prices.max() ?? 0
//                   self?.priceSlider.minimumValue = prices.min() ?? 0
//                   print(self?.priceSlider.maximumValue ?? 0)
//                   print(self?.priceSlider.minimumValue ?? 0)
//                   return products
//               }
               .drive(productsCollectionView.rx.items(cellIdentifier: "ProductCell", cellType: ProductCollectionXIBCell.self)) { [weak self] index, product, cell in
                   cell.productCost.text = String(product.variants?.first??.price ?? "0")
                   cell.productImage.kf.setImage(with: URL(string: product.image?.src ?? ""))
                   cell.productName.text = product.title
                   cell.layer.cornerRadius = 15
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
            heightDimension: .fractionalWidth(0.75)
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
    
    @IBAction func cartBtn(_ sender: Any) {
    }
    
    @IBAction func favBtn(_ sender: Any) {
        coordinator?.goToMainLogin()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
}

