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

//struct Order: Codable {
//    let id: Int? = nil
//    let currency : String? = nil
//    var lineItems: [LineItem]
//    var customer: Customer
//    var billingAddress: Address
//    var shippingAddress: Address
//    var financialStatus: String
//    let contactEmail: String? = nil
//    let createdAt: String? = nil
//    let currentTotalPrice: String? = nil
//    let province: String? = nil
//    let country: String? = nil
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case lineItems = "line_items"
//        case customer
//        case billingAddress = "billing_address"
//        case shippingAddress = "shipping_address"
//        case financialStatus = "financial_status"
//        case currentTotalPrice = "current_total_price"
//        case province
//        case country
//        case contactEmail = "contact_email"
//        case createdAt = "created_at"
//        case currency
//    }
//    
//}
