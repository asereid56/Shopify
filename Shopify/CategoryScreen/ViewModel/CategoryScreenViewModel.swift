//
//  CategoryScreenViewModel.swift
//  Shopify
//
//  Created by Aser Eid on 11/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol CategoryScreenViewModelProtocol {
    var data : Driver<[Product]> { get }
    
    func fetchData(with categoryID : APIEndpoint.RawValue)
    func filterData(selectedSegmentIndex: Int)
    var searchTextSubject: PublishSubject<String> { get }
}

class CategoryScreenViewModel : CategoryScreenViewModelProtocol{
    
    private var productWillFiltered : [Product] = []
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[Product]>(value: [])
    var network : NetworkService
    var searchTextSubject = PublishSubject<String>()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var data: Driver<[Product]> {
        return searchTextSubject
            .startWith("")
            .flatMapLatest { [weak self] text in
                guard let self = self else { return Driver<[Product]>.empty() }
                return self.filteredData(searchText: text)
            }
            .asDriver(onErrorJustReturn: [Product]())
    }
    
    func fetchData(with categoryID: APIEndpoint.RawValue) {
        network.get(endpoint: categoryID)
            .subscribe(onNext: { [weak self] (response : ProductsResponse) in
                self?.productWillFiltered = response.products ?? []
                self?.dataSubject.onNext(response.products ?? [])
            },
                       onError: { error in
                print(error)
            },
                       onCompleted: {
                print("fetch product complete")
            })
            .disposed(by: disposeBag)
    }
    
    func filterData(selectedSegmentIndex: Int) {
        let filteredProducts = productWillFiltered.filter { product in
            switch selectedSegmentIndex {
            case 1:
                return product.productType == "TROUSERS"
            case 2:
                return product.productType == "T-SHIRTS"
            case 3:
                return product.productType == "SHOES"
            case 4:
                return product.productType == "ACCESSORIES"
            default:
                return true
            }
        }
        dataSubject.onNext(filteredProducts)
    }
    private func filteredData(searchText: String) -> Driver<[Product]> {
        return dataSubject
            .map { collections in
                if searchText.isEmpty {
                    return collections
                }
                return collections.filter { collection in
                    collection.title!.lowercased().contains(searchText.lowercased())
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
}
