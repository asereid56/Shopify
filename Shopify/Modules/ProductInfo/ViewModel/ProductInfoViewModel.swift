//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
import RxCocoa
import RxSwift
class ProductInfoViewModel {
    
    let network : NetworkServiceProtocol
    let realmManger : RealmManagerProtocol
    let draftOrderId : String
    private var draftOrder : DraftOrder?
    let disposeBag = DisposeBag()
    var endpoint : String?
    var data = PublishSubject<Bool>()
    var reviews: [Review]?
    var product: Product?
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
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
