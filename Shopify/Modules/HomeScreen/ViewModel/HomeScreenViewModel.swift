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
    var isLoading : BehaviorRelay<Bool>{ get }
    var dataFetchCompleted: PublishRelay<Void> { get }
    var dataSubject: BehaviorSubject<[SmartCollection]>{ get }
    var searchTextSubject: PublishSubject<String> { get }
    func getCoupons() -> [PriceRule]
    func fetchBranchs()
    func fetchCoupons()
    func fetchCurrencyRate()
    func getAdsArrCount() -> Int
    func isVerified() -> Bool
}


class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkServiceProtocol
    private let defaults = UserDefaults.standard
    var dataSubject = BehaviorSubject<[SmartCollection]>(value: [])
    let adsArr = [
        AdsItems(image: "pumaAds"),
        AdsItems(image: "nikaAds"),
        AdsItems(image: "reebokAds"),
        AdsItems(image: "filaAds")
    ]
    var adsArray = BehaviorRelay<[AdsItems]>(value: [])
    private var coupons : [PriceRule] = []
    var dataFetchCompleted = PublishRelay<Void>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    var data: Driver<[SmartCollection]> {
        return searchTextSubject
            .startWith("")
            .flatMapLatest { [weak self] text in
                guard let self = self else { return Driver<[SmartCollection]>.empty() }
                return self.filteredData(searchText: text)
            }
            .asDriver(onErrorJustReturn: [SmartCollection]())
    }
    var searchTextSubject = PublishSubject<String>()
    
    
    init(currencyService: CurrencyServiceProtocol, network: NetworkServiceProtocol) {
        self.currencyService = currencyService
        self.network = network
        fetchCoupons()
    }
    
    func fetchCoupons() {
        let endpoint = APIEndpoint.allPriceRules.rawValue
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self](priceRulesWrapper : AllPriceRulesWrapper) in
                self?.adsArray.accept(self?.adsArr ?? [])
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
    
    private func filteredData(searchText: String) -> Driver<[SmartCollection]> {
        return dataSubject
            .map { collections in
                if searchText.isEmpty {
                    return collections
                }
                return collections.filter { collection in
                    collection.title.lowercased().contains(searchText.lowercased())
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    func getCoupons() -> [PriceRule]{
        return coupons
    }
    
    func getAdsArrCount() -> Int {
        return adsArr.count
    }
    
    func isVerified() -> Bool {
        return defaults.bool(forKey: Constant.IS_VERIFIED)
    }
    
}
