//
//  Currency.swift
//  Shopify
//
//  Created by Apple on 13/06/2024.
//

import Foundation


// Define the structure for the 'meta' part of the JSON
struct Meta: Codable {
    let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedAt = "last_updated_at"
    }
}

// Define the structure for the 'USD' part of the JSON
struct CurrencyData: Codable {
    let code: String
    let value: Double
}

// Define the structure for the 'data' part of the JSON
struct DataContainer: Codable {
    let egp: CurrencyData
    
    enum CodingKeys: String, CodingKey {
        case egp = "EGP"
    }
}

// Define the root structure that includes 'meta' and 'data'
struct CurrencyResponse: Codable {
    let meta: Meta
    let data: DataContainer
}
