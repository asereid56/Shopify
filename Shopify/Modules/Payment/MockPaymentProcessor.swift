//
//  MockPaymentProcessor.swift
//  Shopify
//
//  Created by Apple on 15/06/2024.
//


import UIKit
import PassKit

protocol PaymentProcessing {
    func createPaymentRequest(countryCode : String , amount : Double)  -> PKPaymentRequest
    func handlePaymentAuthorization(_ payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void)
}

class MockPaymentProcessor: PaymentProcessing {
    func createPaymentRequest(countryCode : String , amount : Double) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.shopify.pay"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = countryCode
        request.currencyCode = UserDefaults.standard.string(forKey: Constant.SELECTED_CURRENCY) ?? Constant.USD
        
        var calcAmount = amount
        
        if UserDefaults.standard.string(forKey: Constant.SELECTED_CURRENCY) == Constant.EGP {
            let stringAmount = CurrencyService.calculatePriceAccordingToCurrency(price: String(amount)).replacingOccurrences(of: "\(Constant.EGP) ", with: "")
            print(stringAmount)
            calcAmount = Double(stringAmount) ?? 0.0
        }
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Products", amount: NSDecimalNumber(decimal: Decimal(calcAmount)))
        ]
        return request
    }
    
    func handlePaymentAuthorization(_ payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let status: PKPaymentAuthorizationStatus = .success
        let result = PKPaymentAuthorizationResult(status: status, errors: nil)
        completion(result)
    }
}

