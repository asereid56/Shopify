//
//  ReviewTableViewCell.swift
//  Shopify.Screens
//
//  Created by Mina on 01/06/2024.
//

import UIKit
import Cosmos
class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewBody: UILabel!
    
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewerImage.layer.cornerRadius = reviewerImage.frame.size.width / 2
                reviewerImage.clipsToBounds = true
        reviewBody.numberOfLines = 0
                reviewBody.lineBreakMode = .byWordWrapping

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
