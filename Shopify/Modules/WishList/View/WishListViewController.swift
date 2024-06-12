//
//  WishListViewController.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit

class WishlistViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewDelegate {
  
    @IBOutlet weak var wishlistCollectionView: UICollectionView!
    
    var coordinator: MainCoordinator?
    var viewModel: WishListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNib()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        wishlistCollectionView.delegate = nil
        wishlistCollectionView.dataSource = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.getItems().count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        configureCell(indexPath)
    }
    @IBAction func goToCart(_ sender: Any) {
        coordinator?.goToShoppingCart()
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
}

extension WishlistViewController {
    func removeItem(id: Int, index: Int) {
        print("id: \(id)")
        viewModel?.items?.remove(at: index)
        self.wishlistCollectionView.reloadData()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        wishlistCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
    }
    
    func configureCell(_ indexPath: IndexPath) -> ProductCollectionXIBCell {
        let cell = wishlistCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionXIBCell
        cell.configure(id: viewModel?.getItems()[indexPath.row].id ?? 0, index: indexPath.row, isBtnHidden: false)
        self.view.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    func setup() {
        let itemWidth = (wishlistCollectionView.frame.width / 2 ) - 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        wishlistCollectionView.collectionViewLayout = layout
    }
}
