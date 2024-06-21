//
//  PriceRule.swift
//  Shopify
//
//  Created by Apple on 20/06/2024.
//

import Foundation

struct PriceRule: Codable {
    let id: Int
    let valueType: String
    let value: String
    let prerequisiteSubtotalRange: String?
    let prerequisiteQuantityRange: String?
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case valueType = "value_type"
        case value
        case prerequisiteSubtotalRange = "prerequisite_subtotal_range"
        case prerequisiteQuantityRange = "prerequisite_quantity_range"
        case title
    }
}

struct PriceRuleWrapper: Codable {
    let priceRule: PriceRule

    enum CodingKeys: String, CodingKey {
        case priceRule = "price_rule"
    }
}


struct AllPriceRulesWrapper: Codable {
    let priceRules: [PriceRule]
    
    // Coding keys to map the JSON keys to the struct properties
    enum CodingKeys: String, CodingKey {
        case priceRules = "price_rules"
    }
}
