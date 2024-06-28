//
//  Brands.swift
//  Shopify
//
//  Created by Aser Eid on 08/06/2024.
//

import Foundation

import Foundation

// MARK: - Root
struct BrandsResponse: Codable {
    let smartCollections: [SmartCollection]
    
    enum CodingKeys: String, CodingKey {
        case smartCollections = "smart_collections"
    }
}

// MARK: - SmartCollection
struct SmartCollection: Codable {
    let id: Int
    let handle: String
    let title: String
    let updatedAt: String
    let bodyHtml: String
    let publishedAt: String
    let sortOrder: String
    let templateSuffix: String?
    let disjunctive: Bool
    let rules: [Rule]
    let publishedScope: String
    let adminGraphqlApiID: String
    let image: BrandImage
    
    enum CodingKeys: String, CodingKey {
        case id
        case handle
        case title
        case updatedAt = "updated_at"
        case bodyHtml = "body_html"
        case publishedAt = "published_at"
        case sortOrder = "sort_order"
        case templateSuffix = "template_suffix"
        case disjunctive
        case rules
        case publishedScope = "published_scope"
        case adminGraphqlApiID = "admin_graphql_api_id"
        case image
    }
}

 //MARK: - Image
struct BrandImage: Codable {
    let createdAt: String
    let alt: String?
    let width: Int
    let height: Int
    let src: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case alt
        case width
        case height
        case src
    }
}

// MARK: - Rule
struct Rule: Codable {
    let column: String
    let relation: String
    let condition: String
}
