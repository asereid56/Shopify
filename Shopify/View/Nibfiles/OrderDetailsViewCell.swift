//
//  OrderDetailsViewCell.swift
//  Shopify
//
//  Created by Aser Eid on 18/06/2024.
//

import UIKit

class OrderDetailsViewCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productVendor: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureImageView()
    }
    
    private func configureImageView() {
        productImage.layer.cornerRadius = 15
        productImage.clipsToBounds = true
    }
}
