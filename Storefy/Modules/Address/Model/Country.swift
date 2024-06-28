//
//  Country.swift
//  Shopify
//
//  Created by Apple on 08/06/2024.
//

import Foundation

struct CountryList: Decodable {
    let countries: [Country]
}

struct Country: Decodable {
    let name: String
    let cities: [String]
}
