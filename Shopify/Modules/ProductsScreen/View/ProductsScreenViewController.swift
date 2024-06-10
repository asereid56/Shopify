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

class ProductsScreenViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var numOfItems: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel : ProductScreenViewModelProtocol?
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
        
        productsCollectionView.delegate = nil
        productsCollectionView.dataSource = nil

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.fetchProducts()
        setUpBinding()
       
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
        
        productsCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
 
    
    @IBAction func sliderDidChanged(_ sender: UISlider) {
    }
    
    @IBAction func filterBtn(_ sender: Any) {
       
    }
    
    
    @IBAction func cartBtn(_ sender: Any) {
    }
    
    
    @IBAction func favBtn(_ sender: Any) {
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.back()
    }
    
    
    
}

extension ProductsScreenViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("brands will appear in binding")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
}
