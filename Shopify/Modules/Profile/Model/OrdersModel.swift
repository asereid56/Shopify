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
    let currency, currentSubtotalPrice: String?
    let currentSubtotalPriceSet: CurrentSet?
    let currentTotalDiscounts: String?
    let currentTotalDiscountsSet: CurrentSet?
    let currentTotalPrice: String?
    let province: String?
    let country: String?

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


