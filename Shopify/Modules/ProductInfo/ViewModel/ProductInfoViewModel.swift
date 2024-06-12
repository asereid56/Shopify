//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
class ProductInfoViewModel {
    var reviews: [Review]?
    var product: Product?
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    init(product: Product) {
        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
    }
    func getReviews() -> [Review]? {
        reviews
    }
}
