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
}

class ProductScreenViewModel : ProductScreenViewModelProtocol {
    
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
            .subscribe(onNext: { (response: ProductsResponse) in
                self.dataSubject.onNext(response.products)
            },
            onError: {error in
                print(error)
                
            },
            onCompleted: {
                print("Fetch Products Complete")
            })
            .disposed(by: disposeBag)
    }
    
    
}
