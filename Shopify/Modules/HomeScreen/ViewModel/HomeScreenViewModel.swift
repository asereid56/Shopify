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
    var dataSubject: BehaviorSubject<[SmartCollection]>{ get }
    var searchTextSubject: PublishSubject<String> { get }
    func fetchBranchs()
    func fetchCurrencyRate()
    
}

class HomeScreenViewModel : HomeScreenViewModelProtocol{
    let currencyService : CurrencyServiceProtocol
    private let disposeBag = DisposeBag()
    private let network : NetworkServiceProtocol
    private let dataSubject = BehaviorSubject<[SmartCollection]>(value: [])
    var dataFetchCompleted = PublishRelay<Void>()
    var isLoading = BehaviorRelay<Bool>(value: false)
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

    init(currencyService: CurrencyServiceProtocol, network: NetworkServiceProtocol) {
        self.currencyService = currencyService
        self.network = network
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
    
}
