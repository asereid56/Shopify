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
    
    
    var viewModel : ProductScreenViewModelProtocol?
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    private var isSortViewHidden = true
    private var sortViewHeight : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
        
        sortView.isHidden = true
        upperConstraintforCollectionView.constant = 8
        
        productsCollectionView.collectionViewLayout = createLayout()
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
        
        viewModel?.data.drive(productsCollectionView.rx.items(cellIdentifier: "ProductCell", cellType: ProductCollectionXIBCell.self)){ [weak self] index , product , cell in
            
            cell.productCost.text = String(product.variants.first??.price ?? "")
            cell.productImage.kf.setImage(with: URL(string: product.image?.src ?? ""))
            cell.productName.text = product.title
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            
            self?.brandName.text = product.vendor
        }.disposed(by: disposeBag)
        
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
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.back()
    }
    
    
}

