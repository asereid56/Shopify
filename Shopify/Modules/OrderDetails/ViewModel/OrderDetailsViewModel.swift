//
//  OrderDetailsViewModel.swift
//  Shopify
//
//  Created by Aser Eid on 18/06/2024.
//

import Foundation

class OrderDetailsViewModel {
    var orderDetails : Order
    
    init(orderDetails: Order) {
        self.orderDetails = orderDetails
    }
    
    func getOrderDetails() -> Order {
        return orderDetails
    }
}
