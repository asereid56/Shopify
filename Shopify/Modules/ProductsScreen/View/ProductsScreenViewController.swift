//
//  ProductsScreenViewController.swift
//  Shopify
//
//  Created by Aser Eid on 04/06/2024.
//

import UIKit

class ProductsScreenViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var numOfItems: UILabel!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var sortView: UIView!
    
    @IBOutlet weak var sortViewHeightConstraint: NSLayoutConstraint!
    
    
    var products : [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ProductCollectionXIBCell", bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: "ProductCell")
        products = [
            Product(image: "nike", name: "ADIDAS | CLASSIC BACKPACK", salary: 100),
            Product(image: "addidas", name: "ADIDAS | CLASSIC BACKPACK", salary: 250),
            Product(image: "puma", name: "ADIDAS | CLASSIC BACKPACK", salary: 300),
            Product(image: "nike", name: "ADIDAS | CLASSIC BACKPACK", salary: 200),
            Product(image: "addidas", name: "CLASSIC BACKPACK | LEGEND INK MULTICOLOUR", salary: 100),
            Product(image: "nike", name: "CLASSIC BACKPACK | LEGEND INK MULTICOLOUR", salary: 150),
            Product(image: "addidas", name: "ADIDAS | CLASSIC BACKPACK", salary: 120),
            Product(image: "nike", name: "Puma", salary: 126),
            Product(image: "puma", name: "Puma", salary: 121),
            Product(image: "nike", name: "Puma", salary: 150),
        ]
        
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
    }
    
    
    
}

extension ProductsScreenViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedAds = products[indexPath.row]
        let cell = productsCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionXIBCell
        
        cell.productCost.text = String(selectedAds.salary)
        cell.productImage.image = UIImage(named: selectedAds.image)
        cell.productName.text = selectedAds.name
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
}
