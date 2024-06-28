//
//  CurrencyService.swift
//  Shopify
//
//  Created by Apple on 13/06/2024.
//

import Foundation
import RxSwift

protocol CurrencyServiceProtocol{
    func fetchCurrencyRate()
    static func calculatePriceAccordingToCurrency( price : String) -> String
}

class CurrencyService : CurrencyServiceProtocol{
    static let shared = CurrencyService()
    private let disposeBag = DisposeBag()
    static private var rate : Double?
    static private let defaults = UserDefaults.standard
    var network : NetworkServiceProtocol?

    private init() {}
    
    func fetchCurrencyRate(){
        let endpoint = APIEndpoint.currencyRate.rawValue.replacingOccurrences(of: "{apikey}", with: NetworkConstants.currencyApiKey).replacingOccurrences(of: "{currencies}", with: Constant.EGP).replacingOccurrences(of: "{base_currency}", with: Constant.USD)
        network?.get(url: NetworkConstants.currencyBaseURL, endpoint: endpoint, parameters: nil, headers: nil).subscribe(onNext: {(currencyResponse:CurrencyResponse) in
            CurrencyService.rate = currencyResponse.data.egp.value
            CurrencyService.defaults.set(currencyResponse.data.egp.value, forKey: Constant.CRRENCY_RATE)
            print(currencyResponse.data.egp.value)
        }, onError: { error in
            print("Error fetching Currency: \(error)")
        })
        .disposed(by: disposeBag)
        
    }
    
    static func calculatePriceAccordingToCurrency( price : String) -> String{
        let selectedCurrency = defaults.string(forKey: Constant.SELECTED_CURRENCY) ?? Constant.USD
        switch selectedCurrency {
        case Constant.EGP:
            let priceValue = Double(price) ?? 0.0
            let rateValue = rate ?? 0.0
            return String(format: "EGP %.2f", abs(priceValue * rateValue))
        case Constant.USD:
            let priceValue = abs(Double(price) ?? 0.0)
            return "$\(priceValue)"
        default:
            return "0.0"
        }
    }
    
    static func getPriceAccordingToCurrency( price : String) -> Double{
        let selectedCurrency = defaults.string(forKey: Constant.SELECTED_CURRENCY) ?? Constant.USD
        switch selectedCurrency {
        case Constant.EGP:
            let priceValue = Double(price) ?? 0.0
            let rateValue = rate ?? 0.0
            return Double(priceValue * rateValue)
        case Constant.USD:
            let priceValue = Double(price) ?? 0.0
            return priceValue
        default:
            return 0
        }
    }
}


