//
//  UtilMethods.swift
//  Shopify
//
//  Created by Mina on 15/06/2024.
//

import UIKit
import Reachability

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

func isInternetAvailable() -> Bool {
    let reachability = try! Reachability()
    switch reachability.connection {
    case .wifi, .cellular:
        return true
    case .unavailable:
        return false
    }
}

func checkInternetAndShowToast(vc: UIViewController) -> Bool{
    if isInternetAvailable() {
        return true
    } else {
        showToast(message: "No internet connection", vc: vc)
        return false
    }
}

func formateTheDate(date : String) -> String{
    var formattedDate : String = ""

    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
    
    if let date = inputFormatter.date(from: date) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        
        formattedDate = outputFormatter.string(from: date)
        
    }
    return formattedDate
  
}
