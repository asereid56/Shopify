//
//  PaymentMethodViewModel.swift
//  Shopify
//
//  Created by Apple on 15/06/2024.
//

import Foundation

protocol PaymentMethodViewModelProtocol{
    func setPaymentMethod(method : String)
    func getPaymentMethod() -> String
}


class PaymentMethodViewModel : PaymentMethodViewModelProtocol{
    private let defaults = UserDefaults.standard
    
    func setPaymentMethod(method : String){
        defaults.setValue(method, forKey:  Constant.PAYMENT_METHOD)
    }
    
    func getPaymentMethod() -> String {
        return defaults.string(forKey: Constant.PAYMENT_METHOD) ?? Constant.APPLE_PAY
    }
    
    
}
