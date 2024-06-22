//
//  ReviewsViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
import RxSwift
class ReviewsViewModel {
    var reviews: [Review]!
    var reviewsData = PublishSubject<[Review]>()
    init() {
        reviews = generateReviews()
    }
    func getReviews() {
        reviewsData.onNext(reviews)
    }
}
