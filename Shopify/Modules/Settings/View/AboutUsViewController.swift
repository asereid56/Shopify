//
//  AboutUsViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit

class AboutUsViewController: UIViewController  , Storyboarded {
    @IBOutlet weak var firstMemeberImg: UIImageView!
    @IBOutlet weak var thirdMemberImg: UIImageView!
    @IBOutlet weak var secondMemberImg: UIImageView!
    var coordinator : MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setUpImages()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
    
    private func setUpImages() {
        // Make the UIImageView circular
        firstMemeberImg.layer.cornerRadius = firstMemeberImg.frame.size.width / 2
        firstMemeberImg.clipsToBounds = true
        
        secondMemberImg.layer.cornerRadius = secondMemberImg.frame.size.width / 2
        secondMemberImg.clipsToBounds = true
        
        thirdMemberImg.layer.cornerRadius = thirdMemberImg.frame.size.width / 2
        thirdMemberImg.clipsToBounds = true
        
        // Optional: Add a border to the circular image view
        firstMemeberImg.layer.borderWidth = 2.0
        firstMemeberImg.layer.borderColor = UIColor(hex: "#9775FA").cgColor
        
        secondMemberImg.layer.borderWidth = 2.0
        secondMemberImg.layer.borderColor = UIColor(hex: "#9775FA").cgColor
        
        thirdMemberImg.layer.borderWidth = 2.0
        thirdMemberImg.layer.borderColor = UIColor(hex: "#9775FA").cgColor
    }
}




extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        assert(hexString.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

