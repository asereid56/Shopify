//
//  BrandsCollectionXIBCell.swift
//  Shopify
//
//  Created by Aser Eid on 08/06/2024.
//

import UIKit

class BrandsCollectionXIBCell: UICollectionViewCell {

    @IBOutlet weak var brandImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        brandImage.layer.cornerRadius = 15
        brandImage.layer.masksToBounds = true
        brandImage.layer.borderColor = UIColor.black.cgColor
        brandImage.layer.borderWidth = 1.0
    }

}
