//
//  UtilMethods.swift
//  Shopify
//
//  Created by Mina on 15/06/2024.
//

import UIKit

func showToast(message: String, vc: UIViewController, actions: [UIAlertAction]? = nil) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
    if let actions {
        for action in actions {
            alert.addAction(action)
        }
    }
    vc.present(alert, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        alert.dismiss(animated: true)
    }
}

func checkonUserDefaultsValues() {
    print("customer id: \(UserDefaultsManager.shared.getCartIdFromUserDefaults() ?? "")")
    print("customer first name: \(UserDefaultsManager.shared.getFirstNameFromUserDefaults() ?? "")")
    print("customer last name: \(UserDefaultsManager.shared.getLastNameFromUserDefaults() ?? "")")
    print("wishlist id: \(UserDefaultsManager.shared.getWishListIdFromUserDefaults() ?? "")")
    print("cart id: \(UserDefaultsManager.shared.getCartIdFromUserDefaults() ?? "")")
}
