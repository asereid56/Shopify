//
//  Products.swift
//  Shopify
//
//  Created by Aser Eid on 08/06/2024.
//

import Foundation

struct ProductsResponse: Codable {
    let products: [Product]?
}

// MARK: - Product

struct Product: Codable {
    let id: Int?
    let title: String?
    let bodyHTML: String?
    let vendor: String?
    let productType: String?
    let createdAt: String?
    let handle: String?
    let updatedAt: String?
    let publishedAt: String?
    let templateSuffix: String?
    let publishedScope: String?
    let tags: String?
    let status: String?
    let adminGraphqlAPIID: String?
    let variants: [Variant?]?
    let options: [Option?]?
    let images: [ProductImage?]?
    let image: ProductImage?

    enum CodingKeys: String, CodingKey {
        case id, title
        case bodyHTML = "body_html"
        case vendor
        case productType = "product_type"
        case createdAt = "created_at"
        case handle
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case tags, status
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case variants, options, images, image
    }
}

// MARK: - ProductImage

struct ProductImage: Codable {
    let id: Int64?
    let alt: String?
    let position: Int?
    let productID: Int64?
    let createdAt: String?
    let updatedAt: String?
    let adminGraphqlAPIID: String?
    let width: Int?
    let height: Int?
    let src: String?
    let variantIDS: [Int64]?

    enum CodingKeys: String, CodingKey {
        case id, alt, position
        case productID = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case width, height, src
        case variantIDS = "variant_ids"
    }
}

// MARK: - Option

struct Option: Codable {
    let id: Int64?
    let productID: Int64?
    let name: String?
    let position: Int?
    let values: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case name, position, values
    }
}

// MARK: - Variant

struct Variantt: Codable {
    let id: Int64?
    let productID: Int64?
    let title: String?
    let price: String?
    let sku: String?
    let position: Int?
    let inventoryPolicy: String?
    let compareAtPrice: String?
    let fulfillmentService: String?
    let inventoryManagement: String?
    let option1: String?
    let option2: String?
    let option3: String?
    let createdAt: String?
    let updatedAt: String?
    let taxable: Bool?
    let barcode: String?
    let grams: Int?
    let weight: Double?
    let weightUnit: String?
    let inventoryItemID: Int64?
    let inventoryQuantity: Int?
    let oldInventoryQuantity: Int?
    let requiresShipping: Bool?
    let adminGraphqlAPIID: String?
    let imageID: Int64?

    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case title, price, sku, position
        case inventoryPolicy = "inventory_policy"
        case compareAtPrice = "compare_at_price"
        case fulfillmentService = "fulfillment_service"
        case inventoryManagement = "inventory_management"
        case option1, option2, option3
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxable, barcode, grams, weight
        case weightUnit = "weight_unit"
        case inventoryItemID = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
        case oldInventoryQuantity = "old_inventory_quantity"
        case requiresShipping = "requires_shipping"
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case imageID = "image_id"
    }
}
