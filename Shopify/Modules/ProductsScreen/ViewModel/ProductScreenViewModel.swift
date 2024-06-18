//
//  ProductScreenViewModel.swift
//  Shopify
//
//  Created by Aser Eid on 08/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProductScreenViewModelProtocol {
    var data : Driver<[Product]>{ get }
    var productsCount : Observable<Int>{ get }
    var isLoading : BehaviorRelay<Bool>{ get }
    var dataFetchCompleted: PublishRelay<Void> { get }
    var priceRange: BehaviorRelay<(min: Float, max: Float)> { get }
    
    func fetchProducts()
    func filteredTheProducts(price : Float)
    func convertPriceToCurrency(price : String) -> String
}

class ProductScreenViewModel : ProductScreenViewModelProtocol {
    
    private var filteredProducts : [Product] = []
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[Product]>(value: [])
    var network : NetworkService
    var brandId : String
    var dataFetchCompleted = PublishRelay<Void>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    var priceRange = BehaviorRelay<(min: Float, max: Float)>(value: (0, 100))
   
    
    var data: Driver<[Product]>{
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    var productsCount : Observable<Int>{
        return dataSubject.map { $0.count }.asObservable()
    }
    
    init(network: NetworkService, brandId: String) {
        self.network = network
        self.brandId = brandId
    }
    
    func convertPriceToCurrency(price : String) -> String {
        return CurrencyService
            .calculatePriceAccordingToCurrency(price: price)
    }
    
    func fetchProducts() {
        let endpoint = APIEndpoint.products.rawValue.replacingOccurrences(of: "{brand_id}", with: brandId)
        network.get(endpoint: endpoint)
            .subscribe(onNext: { [weak self] (response: ProductsResponse) in
                
                self?.filteredProducts = response.products ?? []
                self?.dataSubject.onNext(response.products ?? [])
                self?.isLoading.accept(false)
                self?.dataFetchCompleted.accept(())
                
                if let minPrice = response.products?.map({ $0.variants?.first??.price ?? "0" }).compactMap(Float.init).min(),
                   let maxPrice = response.products?.map({ $0.variants?.first??.price ?? "0" }).compactMap(Float.init).max() {
                    
                    self?.priceRange.accept((minPrice, maxPrice))
                }
            },
                       onError: {error in
                print(error)
                self.isLoading.accept(false)
            },
                       onCompleted: {
                print("Fetch Products Complete")
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func filteredTheProducts(price : Float) {
        let filteredProduct = filteredProducts.filter{ products in
            Float(products.variants?.first??.price ?? "0") ?? 0 <= price
        }
        dataSubject.onNext(filteredProduct)
    }
    
}
