//
//  UserDefaultsManager.swift
//  Shopify
//
//  Created by Mina on 15/06/2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    func saveUserInfoToUserDefaults(customerId: String, ordersId: String, wishListId: String, firstName: String, lastName: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(customerId, forKey: "customerId")
        userDefaults.set(ordersId, forKey: "ordersId")
        userDefaults.set(wishListId, forKey: "wishListId")
        userDefaults.set(firstName, forKey: "firstName")
        userDefaults.set(lastName, forKey: "lastName")
    }

    func getCustomerIdFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: "customerId")
    }
    func getCartIdFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: "ordersId")
    }
    func getWishListIdFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: "wishListId")
    }
    func getFirstNameFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: "firstName")
    }
    func getLastNameFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: "lastName")
    }
    
    func clearDefaults() {
        UserDefaults.standard.setValue("", forKey: "customerId")
        UserDefaults.standard.setValue("", forKey: "ordersId")
        UserDefaults.standard.setValue("", forKey: "wishListId")
        UserDefaults.standard.setValue("", forKey: "firstName")
        UserDefaults.standard.setValue("", forKey: "lastName")
        UserDefaults.standard.setValue("", forKey: "PRIMARY_ADDRESS_ID")
    }
}
