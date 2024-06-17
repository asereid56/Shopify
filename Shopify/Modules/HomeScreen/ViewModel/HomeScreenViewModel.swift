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
    
    func fetchBranchs()
    func fetchCurrencyRate()
}

class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkService
    private let dataSubject = BehaviorSubject<[SmartCollection]>(value: [])
    
    init(currencyService: CurrencyServiceProtocol, network: NetworkService) {
        self.currencyService = currencyService
        self.network = network
    }
    
    var data : Driver<[SmartCollection]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    
    func fetchBranchs() {
        network.get(endpoint: APIEndpoint.brands.rawValue)
            .subscribe(
                onNext: { (data : BrandsResponse) in
                    self.dataSubject.onNext(data.smartCollections)
                    print(data.smartCollections.count)
                }, onError: { error in
                    print(error)
                },onCompleted: {
                    print("Fetch completed")
                }
            ).disposed(by: disposeBag)
    }
    
    func fetchCurrencyRate(){
        currencyService.fetchCurrencyRate()
    }
}
