//
//  Discount.swift
//  Shopify
//
//  Created by Apple on 20/06/2024.
//

import Foundation

struct DiscountCode: Codable {
    var id: Int?
    var priceRuleId: Int?
    var code: String?
    var usageCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case priceRuleId = "price_rule_id"
        case code
        case usageCount = "usage_count"
    }
}

struct DiscountCodeWrapper: Codable {
    var discountCode: DiscountCode

    enum CodingKeys: String, CodingKey {
        case discountCode = "discount_code"
    }
}
