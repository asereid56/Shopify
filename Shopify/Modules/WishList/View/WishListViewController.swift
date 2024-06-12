//
//  WishListViewController.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit

class WishlistViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewDelegate {
    var coordinator: MainCoordinator?
    var viewModel: WishListViewModel?
    
    @IBOutlet weak var wishlistCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNib()
        setup()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.getItems().count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        configureCell(indexPath)
    }
    @IBAction func goToCart(_ sender: Any) {
        //coordinator.goToCart()
    }
}

extension WishlistViewController {
    func removeItem(id: Int, index: Int) {
        print("id: \(id)")
        viewModel?.items?.remove(at: index)
        self.wishlistCollectionView.reloadData()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "WishlistCollectionViewCell", bundle: .main)
        wishlistCollectionView.register(nib, forCellWithReuseIdentifier: "wishlistCell")
    }
    
    func configureCell(_ indexPath: IndexPath) -> WishListCollectionViewCell {
        let cell = wishlistCollectionView.dequeueReusableCell(withReuseIdentifier: "wishlistCell", for: indexPath) as! WishListCollectionViewCell
        cell.configure(id: viewModel?.getItems()[indexPath.row].id ?? 0, index: indexPath.row)
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
