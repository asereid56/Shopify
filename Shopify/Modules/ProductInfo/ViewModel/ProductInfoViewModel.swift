//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
import RxSwift
import RxAlamofire
class ProductInfoViewModel {
    var network: NetworkService?
    var reviews: [Review]?
    var product: Product?
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    
    init(product: Product) {
        self.network = NetworkService.shared
        self.product = product
        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
    }
    
    func getReviews() -> [Review]? {
        reviews
    }
    
    func addToWishList(product: Product?) {
        guard let product = product,
              let productId = product.id,
              let title = product.title,
              let price = product.variants?.first??.price,
              let imageSrc = product.image?.src else {
            print("Error: Incomplete product information")
            return
        }
        let draftOrderId = "1110462660761"
        let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)

        _ = network?.get(endpoint: endpoint)
            .flatMap { (data: DraftOrderWrapper) -> Observable<(Bool, String?, DraftOrderWrapper?)> in
                var workingData = data
                let lineItem = LineItem(productId: productId, title: title, price: price, img: imageSrc, quantity: 1, variantTitle: String(productId))
                print("LINE ITEM: \(lineItem)")
                workingData.draftOrder?.lineItems?.append(lineItem)
                return self.network?.put(endpoint: endpoint, body: workingData, responseType: DraftOrderWrapper.self)
                        ?? Observable.empty()
            }
            .subscribe(
                onNext: { success, response, updatedDraftOrder in
                    if success {
                        print("Added to wishlist: \(response ?? "Unknown response")")
                    } else {
                        print("Failed to add to wishlist: \(response ?? "Unknown response")")
                    }
                },
                onError: { error in
                    print("Error adding to wishlist: \(error.localizedDescription)")
                }
            )
    }



}
