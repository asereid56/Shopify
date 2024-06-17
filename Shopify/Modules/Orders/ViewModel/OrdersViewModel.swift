//
//  OrdersViewModel.swift
//  Shopify
//
//  Created by Aser Eid on 17/06/2024.
//

import Foundation

class OrdersViewModel {
    var orders : [Order]
    
    init(orders: [Order]) {
        self.orders = orders
    }
    
    func getOrders() -> [Order] {
        return orders
    }
}
