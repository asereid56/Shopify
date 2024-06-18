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
    var isLoading : BehaviorRelay<Bool>{ get }
    var dataFetchCompleted: PublishRelay<Void> { get }
    
    func fetchBranchs()
    func fetchCurrencyRate()
}

class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkService
    private let dataSubject = BehaviorSubject<[SmartCollection]>(value: [])
    var dataFetchCompleted = PublishRelay<Void>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    var data : Driver<[SmartCollection]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    
   
    
    init(currencyService: CurrencyServiceProtocol, network: NetworkService) {
        self.currencyService = currencyService
        self.network = network
    }
    
   
    
    func fetchBranchs() {
        network.get(endpoint: APIEndpoint.brands.rawValue)
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
}
