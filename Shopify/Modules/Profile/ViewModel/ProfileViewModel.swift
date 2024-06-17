//
//  ProfileViewModel.swift
//  Shopify
//
//  Created by Mina on 16/06/2024.
//

import Foundation
import RxSwift
import RxCocoa
class ProfileViewModel {
    
    var network: NetworkService?
    var customerId: String?
    var wishlistId: String?
    
    private let dataSubject = BehaviorSubject<[Order]>(value: [])
    private let wishListSubject = BehaviorSubject<[LineItem]>(value: [])
    
    init(network: NetworkService? = nil) {
        self.network = network
        customerId = UserDefaultsManager.shared.getCustomerIdFromUserDefaults()
        wishlistId = UserDefaultsManager.shared.getWishListIdFromUserDefaults()
    }
    
    var data : Driver<[Order]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    var wishlistData : Driver<[LineItem]> {
        return wishListSubject.asDriver(onErrorJustReturn: [])
    }
    
    func getOrders() {
        _ = network?.get(endpoint: APIEndpoint.ordersByCustomer.rawValue.replacingOccurrences(of: "{customer_id}", with: customerId ?? "")).subscribe(onNext: { [weak self] (apiResponse: OrdersWrapper) in
            self?.dataSubject.onNext(apiResponse.orders)
        }, onError: { error in
            print("Error fetching orders \(error)")
        })
    }
    
    func getWishListItems() {
        _ = network?.get(endpoint: APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: wishlistId ?? "")).subscribe(onNext: { [weak self] (apiResponse: DraftOrderWrapper) in
            self?.wishListSubject.onNext(apiResponse.draftOrder?.lineItems ?? [])
        }, onError: { error in
            print("Error fetching orders \(error)")
        })
    }
}
