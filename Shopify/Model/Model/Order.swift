//
//  Order.swift
//  Shopify
//
//  Created by Apple on 16/06/2024.
//

import Foundation

struct OrderWrapper: Codable {
    var order: Order
}

struct Order: Codable {
    var lineItems: [LineItem]
    var customer: Customer
    var billingAddress: Address
    var shippingAddress: Address
    var financialStatus: String
    
    enum CodingKeys: String, CodingKey {
        case lineItems = "line_items"
        case customer
        case billingAddress = "billing_address"
        case shippingAddress = "shipping_address"
        case financialStatus = "financial_status"
    }
}
