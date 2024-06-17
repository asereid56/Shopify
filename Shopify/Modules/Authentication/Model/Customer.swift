//
//  Customer.swift
//  Shopify
//
//  Created by Mina on 08/06/2024.
//

import Foundation
class CustomerResponse: Codable {
    
    var customer: Customer?
    
    init(customer: Customer? = nil) {
        self.customer = customer
    }
}

class Customer: Codable {
    var id: Int?
    var email: String?
    var firstName: String?
    var lastName: String?
    var ordersCount: Int?
    var totalSpent: String?
    var lastOrderId: Int?
    var note: String?
    var verifiedEmail: Bool?
    var tags: String?
    init(tags: String) {
        self.tags = tags
    }
    init(firstName : String , lastName : String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    init(firstName: String) {
        self.firstName = firstName
    }
    
    init(id : Int) {
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
            case id, email, note, tags
            case firstName = "first_name"
            case lastName = "last_name"
            case ordersCount = "orders_count"
            case totalSpent = "total_spent"
            case lastOrderId = "last_order_id"
            case verifiedEmail = "verified_email"
        }
    }
