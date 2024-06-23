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
    var isLoading : BehaviorRelay<Bool> { get }
    var isEmpty : Observable<Bool> { get }
    var searchTextSubject: PublishSubject<String> { get }
    func fetchData(with categoryID : APIEndpoint.RawValue)
    func filterData(selectedSegmentIndex: Int)
    func setCategory(category : String)
    func getCategory() -> String
   
}

class CategoryScreenViewModel : CategoryScreenViewModelProtocol{
    
    private var productWillFiltered : [Product] = []
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[Product]>(value: [])
    private var defaults = UserDefaults.standard
    var network : NetworkServiceProtocol
    var searchTextSubject = PublishSubject<String>()
    
    var isLoading =  BehaviorRelay<Bool>(value: true)
    
    var isEmpty: Observable<Bool> {
        return dataSubject.map { $0.isEmpty }
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
    
    init(network: NetworkServiceProtocol) {
        self.network = network
    }
    
    func fetchData(with categoryID: APIEndpoint.RawValue) {
        network.get(url: NetworkConstants.baseURL, endpoint: categoryID, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self] (response : ProductsResponse) in
                self?.productWillFiltered = response.products ?? []
                self?.dataSubject.onNext(response.products ?? [])
                self?.isLoading.accept(false)
            },
                       onError: { error in
                print(error)
                self.isLoading.accept(false)
            },
                       onCompleted: {
                print("fetch product complete")
                self.isLoading.accept(false)
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
    
    func setCategory(category : String) {
        defaults.set(category, forKey: Constant.CATEGORY)
    }
    
    func getCategory() -> String{
        return defaults.string(forKey: Constant.CATEGORY) ?? Constant.WOMEN
    }
    
}
