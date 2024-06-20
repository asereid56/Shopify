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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        productImage.layer.cornerRadius = 15
        productImage.layer.masksToBounds = true
        productImage.layer.borderColor = UIColor.lightGray.cgColor
        productImage.layer.borderWidth = 1.0
        
    }
}
