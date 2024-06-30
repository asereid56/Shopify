//
//  OnBoardingCollectionViewCell.swift
//  Storefy
//
//  Created by Aser Eid on 29/06/2024.
//

import UIKit

class OnBoardingCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textDetails: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(onBoardItem : OnboardModel){
        imageCell.image = UIImage(named: onBoardItem.img)
        title.text = onBoardItem.title
        textDetails.text = onBoardItem.txtDetails
    }

}
