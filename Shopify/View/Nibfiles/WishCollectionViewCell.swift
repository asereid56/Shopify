//
//  WishCollectionViewCell.swift
//  Shopify
//
//  Created by Mina on 13/06/2024.
//

import UIKit
import RxSwift

class WishCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var id: Int?
    var index: Int?
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImage.layer.cornerRadius = 15
        itemImage.layer.masksToBounds = true
        itemImage.layer.borderColor = UIColor.lightGray.cgColor
        itemImage.layer.borderWidth = 1.0
    }
    
    func configure(_ index: Int) {
        self.index = index
    }
    
    func configure(with item: LineItem) {
        let array = item.sku?.components(separatedBy: " ")
        itemImage.kf.setImage(with: URL(string: array?[0] ?? ""))
        itemCost.text =  CurrencyService.calculatePriceAccordingToCurrency(price: String(item.price ?? "0"))
        itemTitle.text = item.title
    }
}
