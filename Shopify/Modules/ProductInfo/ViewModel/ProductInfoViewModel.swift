//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
class ProductInfoViewModel {
    var network: NetworkService?
    let isLoading = BehaviorRelay<Bool>(value: false)
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
    
    func addToWishList(product: Product?, vc: UIViewController, completion: @escaping (Bool) -> Void) {
        isLoading.accept(true)
        guard let product = product,
              let productId = product.id,
              let title = product.title,
              let price = product.variants?.first??.price,
              let imageSrc = product.image?.src else {
            print("Error: Incomplete product information")
            return
        }
        let draftOrderId = UserDefaultsManager.shared.getWishListIdFromUserDefaults()
        let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId ?? "")

        _ = network?.get(endpoint: endpoint)
            .flatMap { (data: DraftOrderWrapper) -> Observable<(Bool, String?, DraftOrderWrapper?)> in
                var workingData = data
                if ((workingData.draftOrder!.lineItems!.contains(where: { $0.title == product.title }))) {
                    self.isLoading.accept(false)
                    completion(false)
                    return Observable.just((false, nil, nil))
                }
                let lineItem = LineItem(productId: productId, title: title, price: price, img: imageSrc, quantity: 1, variantTitle: String(productId))
                print("LINE ITEM: \(lineItem)")
                workingData.draftOrder?.lineItems?.append(lineItem)
                return self.network?.put(endpoint: endpoint, body: workingData, responseType: DraftOrderWrapper.self)
                        ?? Observable.empty()
            }
            .subscribe(
                onNext: { success, response, updatedDraftOrder in
                    if success {
                        self.isLoading.accept(false)
                        completion(true)
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

    func getSelectedVariant(title: String) -> Variantt? {
        let variants = product?.variants?.filter{ $0?.title == title }
        return variants?[0]
    }

}
