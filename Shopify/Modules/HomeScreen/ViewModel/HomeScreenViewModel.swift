//
//  HomeScreenViewModel.swift
//  Shopify
//
//  Created by Aser Eid on 08/06/2024.
//

import Foundation
import RxCocoa
import RxSwift

protocol HomeScreenViewModelProtocol {
    var data : Driver<[SmartCollection]>{ get }
    var adsArray : BehaviorRelay<[AdsItems]> {get}
   // var coupons : PublishSubject<[PriceRule]> {get}
    var isLoading : BehaviorRelay<Bool>{ get }
    var dataFetchCompleted: PublishRelay<Void> { get }
    func getCoupons() -> [PriceRule]
    func fetchBranchs()
    func fetchCurrencyRate()
}


class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkServiceProtocol
    private let dataSubject = BehaviorSubject<[SmartCollection]>(value: [])

    var adsArray = BehaviorRelay<[AdsItems]>(value: [])
    private var coupons : [PriceRule] = []
    var dataFetchCompleted = PublishRelay<Void>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    var data : Driver<[SmartCollection]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    
   
    
    init(currencyService: CurrencyServiceProtocol, network: NetworkServiceProtocol) {
        self.currencyService = currencyService
        self.network = network
        fetchCoupons()
    }
    
    private func fetchCoupons() {
        let endpoint = APIEndpoint.allPriceRules.rawValue
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self](priceRulesWrapper : AllPriceRulesWrapper) in
                let adsArr = [
                    AdsItems(image: "addidasAds"),
                    AdsItems(image: "pumaAds"),
                    AdsItems(image: "nikaAds"),
                    AdsItems(image: "reebokAds"),
                   // AdsItems(image: "filaAds")
                ]
                self?.adsArray.accept(adsArr)
                self?.coupons = priceRulesWrapper.priceRules
               // self?.coupons.onNext(priceRulesWrapper.priceRules)
            }).disposed(by: disposeBag)
    }
    
   
    
    func fetchBranchs() {
        network.get(url: NetworkConstants.baseURL, endpoint: APIEndpoint.brands.rawValue, parameters: nil, headers: nil)
            .subscribe(
                onNext: { [ weak self ] (data : BrandsResponse) in
                    self?.dataSubject.onNext(data.smartCollections)
                    self?.isLoading.accept(false)
                    self?.dataFetchCompleted.accept(())
                }, onError: { error in
                    print(error)
                    self.isLoading.accept(false)
                },onCompleted: {
                    print("Fetch completed")
                    self.isLoading.accept(false)
                }
            ).disposed(by: disposeBag)
    }
    
    func fetchCurrencyRate(){
        currencyService.fetchCurrencyRate()
    }
    
    func getCoupons() -> [PriceRule]{
        return coupons
    }
}
