//
//  WishListCollectionViewCell.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
//protocol CollectionViewDelegate: AnyObject {
//    func removeItem(id: Int, index: Int)
//}
class WishListCollectionViewCell: UICollectionViewCell {
    weak var delegate: CollectionViewDelegate?
    var id: Int?
    var index: Int?
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 24
//        itemImage.layer.cornerRadius = 24
        faveButton.layer.cornerRadius = 24
    }
    func configure(id: Int, index: Int) {
        self.id = id
        self.index = index
    }
    @IBAction func removeFromWishlist(_ sender: Any) {
        delegate?.removeItem(id: id!, index: index!)
    }
    
}
