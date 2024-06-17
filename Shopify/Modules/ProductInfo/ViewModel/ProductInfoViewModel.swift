//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class ProductInfoViewModel {
    
    let network : NetworkServiceProtocol
    let realmManger : RealmManagerProtocol
    let draftOrderId : String
    let isLoading = BehaviorRelay<Bool>(value: false)
    private var draftOrder : DraftOrder?
    let disposeBag = DisposeBag()
    var endpoint : String?
    var data = PublishSubject<Bool>()
    var reviews: [Review]?
    var product: Product?
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    
//    init(product: Product) {
//        self.network = NetworkService.shared
//        self.product = product
//    }
    
    init(product: Product , network : NetworkServiceProtocol , draftOrderId : String , realmManger : RealmManagerProtocol) {

        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
        self.product = product
        self.network = network
        self.draftOrderId = draftOrderId
        endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)
        self.realmManger = realmManger
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

        _ = network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
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
                return self.network.put(url: NetworkConstants.baseURL, endpoint: endpoint, body: workingData, headers: nil, responseType: DraftOrderWrapper.self) ?? Observable.empty()
//                return self.network?.put(endpoint: endpoint, body: workingData, responseType: DraftOrderWrapper.self)
                        
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

    func getSelectedVariant(title: String) -> Variant? {
        let variants = product?.variants?.filter{ $0?.title == title }
        return variants?[0]
    }

    func fetchDraftOrder(){
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint!, parameters: nil, headers: nil).subscribe {[weak self] (draftOrderWrapper : DraftOrderWrapper) in
            self?.draftOrder = draftOrderWrapper.draftOrder
            let variant = self?.product?.variants![0]
            self?.updateLineItem(variant: variant!)
            
        }.disposed(by: disposeBag)
    }
    
    
    func updateLineItem(variant : Variant){
        let lineItems = draftOrder?.lineItems
        for lineItem in lineItems! {
            if lineItem.variantId == variant.id {
                data.onNext(false)
                return
            }
        }
        let properties = Property(name: "img", value: (product?.image?.src)!)
        let newProduct = LineItem(variantId: variant.id!, productId: variant.productId!, properties: [properties])
        draftOrder?.lineItems?.append(newProduct)
        let wrapper = DraftOrderWrapper(draftOrder: draftOrder)
        network.put(url: NetworkConstants.baseURL, endpoint: endpoint ?? "", body: wrapper, headers: nil, responseType: DraftOrderWrapper.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] (success, message, response) in
                if response != nil {
                    self?.data.onNext(true)
                    let realmDraftOrder = response?.draftOrder.map { RealmDraftOrder(draftOrder: $0)}
                   // print(realmDraftOrder?.id)
                    self?.realmManger.deleteAllThenAdd(realmDraftOrder!, RealmDraftOrder.self)
                    print(self?.realmManger.getAll(RealmDraftOrder.self).count)
                }
             
            }, onError: { error in
                print("Error updating draft order: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    
}
