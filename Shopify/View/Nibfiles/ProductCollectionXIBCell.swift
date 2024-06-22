//
//  ProductCollectionXIBCell.swift
//  Shopify
//
//  Created by Aser Eid on 04/06/2024.
//

import UIKit

protocol CollectionViewDelegate: AnyObject {
    func removeItem(id: Int, index: Int)
}

class ProductCollectionXIBCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCost: UILabel!
    @IBOutlet weak var costSign: UILabel!
    @IBOutlet weak var deletebtn: UIButton!
    
    
    //weak var delegate: CollectionViewDelegate?
    var id: Int?
    var index: Int?
    var isBtnHidden : Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        productImage.layer.cornerRadius = 15
        productImage.layer.masksToBounds = true
        productImage.layer.borderColor = UIColor.lightGray.cgColor
        productImage.layer.borderWidth = 1.0
        deletebtn.isHidden = isBtnHidden
        
    }
    
    func configure(id: Int, index: Int , isBtnHidden : Bool?) {
        self.id = id
        self.index = index
        self.isBtnHidden = isBtnHidden ?? true
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        //delegate?.removeItem(id: id!, index: index!)
    }
    
}
