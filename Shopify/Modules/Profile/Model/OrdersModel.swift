//
//  OrdersModel.swift
//  Shopify
//
//  Created by Mina on 16/06/2024.
//

import Foundation
struct OrdersWrapper: Codable {
    let orders: [Order]
}

struct Order: Codable {
    let id: Int?
    let contactEmail: String?
    let createdAt: String? 
    let currency : String?
    let currentSubtotalPrice: String?
    let currentSubtotalPriceSet: CurrentSet?
    let currentTotalDiscounts: String?
    let currentTotalDiscountsSet: CurrentSet?
    let currentTotalPrice: String?
    let province: String?
    let country: String?
 
    var lineItems: [LineItem]?
    var customer: Customer
    var billingAddress: Address?
    var shippingAddress: Address?
    var financialStatus: String
    
    var discountCodes: [OrderDiscountCode?]?
    
    init(lineItems: [LineItem]? = nil, customer: Customer, billingAddress: Address? = nil, shippingAddress: Address? = nil, financialStatus: String, discountCodes : [OrderDiscountCode?]? = nil) {
        self.id = nil
        self.contactEmail = nil
        self.createdAt = nil
        self.currency = nil
        self.currentSubtotalPrice = nil
        self.currentSubtotalPriceSet = nil
        self.currentTotalDiscounts = nil
        self.currentTotalDiscountsSet = nil
        self.currentTotalPrice = nil
        self.province = nil
        self.country = nil
        self.lineItems = lineItems
        self.customer = customer
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.financialStatus = financialStatus
        self.discountCodes = discountCodes
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case contactEmail = "contact_email"
        case createdAt = "created_at"
        case currency
        case currentSubtotalPrice = "current_subtotal_price"
        case currentSubtotalPriceSet = "current_subtotal_price_set"
        case currentTotalDiscounts = "current_total_discounts"
        case currentTotalDiscountsSet = "current_total_discounts_set"
        case currentTotalPrice = "current_total_price"
        case province
        case country
        case lineItems = "line_items"
        case customer
        case billingAddress = "billing_address"
        case shippingAddress = "shipping_address"
        case financialStatus = "financial_status"
        case discountCodes = "discount_codes"
        
    }
}

struct CurrentSet: Codable {
    let shopMoney, presentmentMoney: Money
    
    enum CodingKeys: String, CodingKey {
        case shopMoney = "shop_money"
        case presentmentMoney = "presentment_money"
    }
}

struct Money: Codable {
    let amount, currencyCode: String
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
    }
}

struct OrderDiscountCode: Codable {
    let code: String
        let amount: String
        let type: String // or enum if you have specific types

        enum CodingKeys: String, CodingKey {
            case code
            case amount
            case type
        }
}


