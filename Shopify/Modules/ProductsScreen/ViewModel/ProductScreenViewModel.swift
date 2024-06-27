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
    func isVerified() -> Bool
    func fetchProducts()
    func filteredTheProducts(price : Float)
    func convertPriceToCurrency(price : String) -> String
}

class ProductScreenViewModel : ProductScreenViewModelProtocol {
    
    private var filteredProducts : [Product] = []
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[Product]>(value: [])
    private let defaults = UserDefaults.standard
    var network : NetworkServiceProtocol
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
    
    init(network: NetworkServiceProtocol, brandId: String) {
        self.network = network
        self.brandId = brandId
    }
    
    func convertPriceToCurrency(price : String) -> String {
        return CurrencyService
            .calculatePriceAccordingToCurrency(price: price)
    }
    
    func fetchProducts() {
        let endpoint = APIEndpoint.products.rawValue.replacingOccurrences(of: "{brand_id}", with: brandId)
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self] (response: ProductsResponse) in
                
                self?.filteredProducts = response.products ?? []
                self?.dataSubject.onNext(response.products ?? [])
                self?.isLoading.accept(false)
                self?.dataFetchCompleted.accept(())
                
                if let minPrice = response.products?.map({ $0.variants?.first??.price ?? "0" }).compactMap(Float.init).min(),
                   let maxPrice = response.products?.map({ $0.variants?.first??.price ?? "0" }).compactMap(Float.init).max() {
                    let min = CurrencyService.getPriceAccordingToCurrency(price: String(minPrice))
                    let max = CurrencyService.getPriceAccordingToCurrency(price: String(maxPrice))
                    self?.priceRange.accept((Float(min), Float(max)))
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
            Float(CurrencyService.getPriceAccordingToCurrency(price: products.variants?.first??.price ?? "0") ) <= price
        }
        dataSubject.onNext(filteredProduct)
    }
    
    func isVerified() -> Bool {
        return defaults.bool(forKey: Constant.IS_VERIFIED)
    }
}
