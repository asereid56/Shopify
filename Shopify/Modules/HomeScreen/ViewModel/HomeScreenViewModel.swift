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
    var dataSubject: BehaviorSubject<[SmartCollection]>{ get }
    var searchTextSubject: PublishSubject<String> { get }
    func fetchBranchs()
    func fetchCurrencyRate()
    
}

class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkService
    var dataSubject = BehaviorSubject<[SmartCollection]>(value: [])
    var searchTextSubject = PublishSubject<String>()
    
    init(currencyService: CurrencyServiceProtocol, network: NetworkService) {
        self.currencyService = currencyService
        self.network = network
    }
    
    var data: Driver<[SmartCollection]> {
        return searchTextSubject
            .startWith("")
            .flatMapLatest { [weak self] text in
                guard let self = self else { return Driver<[SmartCollection]>.empty() }
                return self.filteredData(searchText: text)
            }
            .asDriver(onErrorJustReturn: [SmartCollection]())
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
    
}
