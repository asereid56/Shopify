//
//  RealmDraftOrder.swift
//  Shopify
//
//  Created by Apple on 17/06/2024.
//

import Foundation
import RealmSwift

class RealmLineItem: Object {
  //  @objc dynamic var id: Int = 0
    @objc dynamic var variantId: Int = 0
    @objc dynamic var productId: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var variantTitle: String = ""
    @objc dynamic var sku: String = ""
    @objc dynamic var vendor: String = ""
    @objc dynamic var quantity: Int = 0
    @objc dynamic var requiresShipping: Bool = false
    @objc dynamic var taxable: Bool = false
    @objc dynamic var giftCard: Bool = false
    @objc dynamic var fulfillmentService: String = ""
    @objc dynamic var grams: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var custom: Bool = false
    @objc dynamic var price: String = ""
    @objc dynamic var adminGraphqlApiId: String = ""
    var properties = List<RealmProperty>()
    
    convenience init(title: String?, price: String?, quantity: Int?) {
        self.init()
        self.title = title ?? ""
        self.price = price ?? ""
        self.quantity = quantity ?? 0
    }
    
    convenience init(lineItem: LineItem) {
            self.init()
            
            self.variantId = lineItem.variantId ?? 0
            self.productId = lineItem.productId ?? 0
            self.title = lineItem.title ?? ""
            self.variantTitle = lineItem.variantTitle ?? ""
            self.sku = lineItem.sku ?? ""
            self.vendor = lineItem.vendor ?? ""
            self.quantity = lineItem.quantity ?? 0
            self.requiresShipping = lineItem.requiresShipping ?? false
            self.taxable = lineItem.taxable ?? false
            self.giftCard = lineItem.giftCard ?? false
            self.fulfillmentService = lineItem.fulfillmentService ?? ""
            self.grams = lineItem.grams ?? 0
            self.name = lineItem.name ?? ""
            self.custom = lineItem.custom ?? false
            self.price = lineItem.price ?? ""
            self.adminGraphqlApiId = lineItem.adminGraphqlApiId ?? ""
            
            if let properties = lineItem.properties {
                self.properties.append(objectsIn: properties.map { RealmProperty(name: $0.name ?? "", value: $0.value ?? "") })
            }
        }
    
}

class RealmProperty: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var value: String = ""
    
    convenience init(name: String, value: String) {
        self.init()
        self.name = name
        self.value = value
    }
}

class RealmTaxLine: Object {
    @objc dynamic var rate: Double = 0.0
    @objc dynamic var title: String = ""
    @objc dynamic var price: String = ""
}

class RealmAppliedDiscount: Object {
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var valueType: String = ""
    @objc dynamic var value: String = ""
    @objc dynamic var amount: String = ""
    @objc dynamic var title: String = ""
}
class RealmDraftOrder: Object {
   // @objc dynamic var id: Int = 0
    @objc dynamic var note: String?
    @objc dynamic var email: String?
    @objc dynamic var taxesIncluded: Bool = false
    @objc dynamic var currency: String = ""
    @objc dynamic var invoiceSentAt: String?
    @objc dynamic var createdAt: String?
    @objc dynamic var updatedAt: String?
    @objc dynamic var taxExempt: Bool = false
    @objc dynamic var completedAt: String?
    @objc dynamic var name: String?
    @objc dynamic var status: String?
    var lineItems = List<RealmLineItem>()
    @objc dynamic var shippingAddress: String?
    @objc dynamic var billingAddress: String?
    @objc dynamic var invoiceUrl: String?
    @objc dynamic var appliedDiscount: RealmAppliedDiscount? = nil
    @objc dynamic var orderId: Int = 0
    @objc dynamic var shippingLine: String?
    var taxLines = List<RealmTaxLine>()
    @objc dynamic var tags: String?
    var noteAttributes = List<String>()
    @objc dynamic var totalPrice: String?
    @objc dynamic var subtotalPrice: String?
    @objc dynamic var totalTax: String?
    @objc dynamic var paymentTerms: String?
    @objc dynamic var adminGraphqlApiId: String = ""
    
    convenience init(name: String? = nil, lineItems: [RealmLineItem], email: String? = nil) {
        self.init()
        self.note = name
        self.lineItems.append(objectsIn: lineItems)
        self.email = email
    }
    
    convenience init(draftOrder: DraftOrder) {
        self.init()
        if let lineItems = draftOrder.lineItems {
            self.lineItems.append(objectsIn: lineItems.map { RealmLineItem(lineItem: $0) })
        }
        self.totalPrice = draftOrder.totalPrice
        self.subtotalPrice = draftOrder.subtotalPrice
        self.totalTax = draftOrder.totalTax
    }
}

