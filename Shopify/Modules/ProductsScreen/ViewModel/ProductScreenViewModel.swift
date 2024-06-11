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
    
    func fetchProducts()
    func filteredTheProducts(price : Float)
}

class ProductScreenViewModel : ProductScreenViewModelProtocol {
    
    private var filteredProducts : [Product] = []
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[Product]>(value: [])
    var network : NetworkService
    var brandId : String
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
    
    func fetchProducts() {
        let endpoint = APIEndpoint.products.rawValue.replacingOccurrences(of: "{brand_id}", with: brandId)
        network.get(endpoint: endpoint)
            .subscribe(onNext: { [weak self] (response: ProductsResponse) in
                
                self?.filteredProducts = response.products ?? []
                self?.dataSubject.onNext(response.products ?? [])
            },
            onError: {error in
                print(error)
            },
            onCompleted: {
                print("Fetch Products Complete")
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
