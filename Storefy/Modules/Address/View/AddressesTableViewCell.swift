//
//  AddressesTableViewCell.swift
//  Shopify
//
//  Created by Apple on 07/06/2024.
//

import UIKit

class AddressesTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // selectionStyle = .none
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//    }
}
