//
//  DraftOrder.swift
//  Shopify
//
//  Created by Apple on 10/06/2024.
//

import Foundation

struct LineItem: Codable {
    var id: Int? = 0
    var variantId: Int? = nil
    var productId: Int? = nil
    var title: String? = nil
    var variantTitle: String? = nil
    var sku: String? = nil
    var vendor: String? = nil
    var quantity: Int? = nil
    var requiresShipping: Bool? = nil
    var taxable: Bool? = nil
    var giftCard: Bool? = nil
    var fulfillmentService: String? = nil
    var grams: Int? = nil
    var taxLines: [TaxLine]? = nil
    var appliedDiscount: AppliedDiscount? = nil
    var name: String? = nil
    var properties: [Property]? = nil
    var custom: Bool? = nil
    var price: String? = nil
    var adminGraphqlApiId: String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case variantId = "variant_id"
        case productId = "product_id"
        case title
        case variantTitle = "variant_title"
        case sku
        case vendor
        case quantity
        case requiresShipping = "requires_shipping"
        case taxable
        case giftCard = "gift_card"
        case fulfillmentService = "fulfillment_service"
        case grams
        case taxLines = "tax_lines"
        case appliedDiscount = "applied_discount"
        case name
        case properties
        case custom
        case price
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
    init(title: String?, price: String?, quantity: Int?) {
        self.title = title
        self.price = price
        self.quantity = quantity
    }
    
    init(variantId : Int , productId: Int , quantity: Int = 1 , properties: [Property]) {
        self.variantId = variantId
        self.productId = productId
        self.quantity = quantity
        self.properties = properties
    }
    
    init(from realmLineItem: RealmLineItem) {
        self.variantId = realmLineItem.variantId
        self.productId = realmLineItem.productId
        self.title = realmLineItem.title
        self.variantTitle = realmLineItem.variantTitle
        self.sku = realmLineItem.sku
        self.vendor = realmLineItem.vendor
        self.quantity = realmLineItem.quantity
        self.requiresShipping = realmLineItem.requiresShipping
        self.taxable = realmLineItem.taxable
        self.giftCard = realmLineItem.giftCard
        self.fulfillmentService = realmLineItem.fulfillmentService
        self.grams = realmLineItem.grams
        self.name = realmLineItem.name
        self.custom = realmLineItem.custom
        self.price = realmLineItem.price
        self.adminGraphqlApiId = realmLineItem.adminGraphqlApiId
        
        self.properties = realmLineItem.properties.map { Property(name: $0.name, value: $0.value) }
    }
}
struct Property: Codable {
    let name: String
    let value: String
}
struct TaxLine: Codable {
    let rate: Double?
    let title: String?
    let price: String?
}

struct AppliedDiscount: Codable {
    let description: String?
    let valueType: String?
    let value: String?
    let amount: String?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case valueType = "value_type"
        case value
        case amount
        case title
    }
}

struct DraftOrder: Codable {
    let id: Int? = nil
    var note: String?
    var email: String?
    var taxesIncluded: Bool? = nil
    var currency: String? = nil
    var invoiceSentAt: String? = nil
    var createdAt: String? = nil
    var updatedAt: String? = nil
    var taxExempt: Bool? = nil
    var completedAt: String? = nil
    var name: String?
    var status: String? = nil
    var lineItems: [LineItem]?
    var shippingAddress: String? = nil
    var billingAddress: String? = nil
    var invoiceUrl: String? = nil
    var appliedDiscount: AppliedDiscount? = nil
    var orderId: Int? = nil
    var shippingLine: String? = nil
    var taxLines: [TaxLine]? = nil
    var tags: String? = nil
    var noteAttributes: [String]? = nil
    var totalPrice: String? = nil
    var subtotalPrice: String? = nil
    var totalTax: String? = nil
    var paymentTerms: String? = nil
    var adminGraphqlApiId: String? = nil
    
    init (name: String? = nil, lineItems: [LineItem], email: String? = nil) {
        self.note = name
        self.lineItems = lineItems
        self.email = email
    }
    enum CodingKeys: String, CodingKey {
        case id
        case note
        case email
        case taxesIncluded = "taxes_included"
        case currency
        case invoiceSentAt = "invoice_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxExempt = "tax_exempt"
        case completedAt = "completed_at"
        case name
        case status
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case invoiceUrl = "invoice_url"
        case appliedDiscount = "applied_discount"
        case orderId = "order_id"
        case shippingLine = "shipping_line"
        case taxLines = "tax_lines"
        case tags
        case noteAttributes = "note_attributes"
        case totalPrice = "total_price"
        case subtotalPrice = "subtotal_price"
        case totalTax = "total_tax"
        case paymentTerms = "payment_terms"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
    
    init(from realmDraftOrder: RealmDraftOrder) {
        self.lineItems = realmDraftOrder.lineItems.map { LineItem(from: $0) }
        self.totalPrice = realmDraftOrder.totalPrice
        self.subtotalPrice = realmDraftOrder.subtotalPrice
        self.totalTax = realmDraftOrder.totalTax
    }
}

struct DraftOrderWrapper: Codable {
    var draftOrder: DraftOrder?
    
    enum CodingKeys: String, CodingKey {
        case draftOrder = "draft_order"
    }
}
