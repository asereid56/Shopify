//
//  SettingViewModel.swift
//  Shopify
//
//  Created by Apple on 13/06/2024.
//

import Foundation


protocol SettingViewModelProtocol {
    func saveSelectedCurrency(currency: String)
    func getSelectedCurrency() -> String
}

class SettingViewModel : SettingViewModelProtocol{
    let defaults = UserDefaults.standard
    
    func saveSelectedCurrency(currency: String) {
        defaults.set(currency, forKey: Constant.SELECTED_CURRENCY)
    }

    func getSelectedCurrency() -> String {
        return defaults.string(forKey: Constant.SELECTED_CURRENCY) ?? Constant.USD
    }
    
}
