//
//  Item.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation

struct MyLineItem: Codable {
    var productId: String?
    var title: String?
    var quantity = 1
    var img: String?
    var price: String?
    
}
