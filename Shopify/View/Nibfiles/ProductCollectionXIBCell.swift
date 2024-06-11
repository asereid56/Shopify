//
//  ProductCollectionXIBCell.swift
//  Shopify
//
//  Created by Aser Eid on 04/06/2024.
//

import UIKit

class ProductCollectionXIBCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCost: UILabel!
    @IBOutlet weak var costSign: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        productImage.layer.cornerRadius = 15
        productImage.layer.masksToBounds = true
        productImage.layer.borderColor = UIColor.black.cgColor
        productImage.layer.borderWidth = 1.0
        
    }
    
    @IBAction func favBtn(_ sender: Any) {
    }
    
}
