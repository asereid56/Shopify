//
//  ReviewsViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
class ReviewsViewModel {
    var reviews: [Review]!
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    init() {
        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "1st", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
    }
    func getReviews() -> [Review] {
        return reviews
    }
}
