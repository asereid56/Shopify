//
//  UtilMethods.swift
//  Shopify
//
//  Created by Mina on 15/06/2024.
//

import UIKit
import Reachability

func showToast(title: String? = nil, message: String, vc: UIViewController, actions: [UIAlertAction]? = nil, style: UIAlertController.Style? = nil, selfDismiss: Bool = true, completion: (() -> Void)? = nil) -> UIAlertController? {
    let alert = UIAlertController(title: title, message: message, preferredStyle: style ?? .actionSheet)
    if let actions {
        for action in actions {
            alert.addAction(action)
        }
    }
    vc.present(alert, animated: true)
    if selfDismiss {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true)
            completion?()
        }
        return nil
    }
    else { return alert }
}

func checkonUserDefaultsValues() {
    print("customer id: \(UserDefaultsManager.shared.getCustomerIdFromUserDefaults() ?? "")")
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
        _ = showToast(message: "No internet connection", vc: vc)
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

func generateReviews() -> [Review] {
    let rev1 = Review(img: "reviewer1", reviewBody: "The product is decent for its price. It met my basic expectations and gets the job done, though there is some room for improvement.", rating: 3)
    let rev2 = Review(img: "reviewer2", reviewBody: "Overall, a good product. It has a few minor flaws, but it still serves its purpose well. I would recommend it to others.", rating: 4)
    let rev3 = Review(img: "reviewer3", reviewBody: "Very satisfied with this purchase. The product works well and is easy to use. Great value for the price!", rating: 4)
    let rev4 = Review(img: "reviewer4", reviewBody: "I was pleasantly surprised by the quality. It performs better than I expected. I would buy it again.", rating: 3)
    let rev5 = Review(img: "reviewer5", reviewBody: "This product exceeded my expectations. It’s well-made and reliable. I’ve been using it regularly with no issues.", rating: 4)
    let rev6 = Review(img: "reviewer6", reviewBody: "Fantastic product! It’s high quality and works perfectly. I’m very happy with my purchase and would recommend it to others.", rating: 5)
    let rev7 = Review(img: "reviewer7", reviewBody: "Absolutely love this product! It’s exactly what I needed and works flawlessly. Highly recommend to anyone.", rating: 5)
    let rev8 = Review(img: "reviewer8", reviewBody: "Excellent product! It’s well-designed and performs exceptionally well. I couldn’t be happier with my purchase.", rating: 5)
    let rev9 = Review(img: "reviewer9", reviewBody: "This is one of the best purchases I’ve made. The product is top-notch and has made my life so much easier. Highly recommend!", rating: 5)
    let rev10 = Review(img: "reviewer10", reviewBody: "Perfect! The product is exactly as described and works even better than I expected. Great quality and value for the price.", rating: 4)
    return [rev1, rev2, rev3, rev4, rev5, rev6, rev7, rev8, rev9, rev10]
}
