//
//  ProductInfoViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import RxCocoa
import RxSwift
import UIKit

class ProductInfoViewModel {
    var makeNetworkCall: Bool?
    var productId: String?
    let network : NetworkServiceProtocol
    let realmManger : RealmManagerProtocol
    let draftOrderId : String
    let isLoading = BehaviorRelay<Bool>(value: false)
    private var draftOrder : DraftOrder?
    let disposeBag = DisposeBag()
    var endpoint : String?
    var data = PublishSubject<Bool>()
    var reviewsData = PublishSubject<[Review]>()
    var addToCart = PublishSubject<Bool>()
    var reviews: [Review]?
    var product: Product?
    var wishlistItems: [LineItem]?
    
    
    init(product: Product? , network : NetworkServiceProtocol , draftOrderId : String , realmManger : RealmManagerProtocol, makeNetworkCall: Bool) {
        reviews = Array(generateReviews().prefix(3))
        self.makeNetworkCall = makeNetworkCall
        self.product = product
        self.network = network
        self.draftOrderId = draftOrderId
        endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)
        self.realmManger = realmManger
        
    }
    
    func getReviews() {
        reviewsData.onNext(reviews ?? [])
    }
    
    func getProduct(completion: @escaping () -> ()) {
        _ = network.get(url: NetworkConstants.baseURL, endpoint: APIEndpoint.singeProduct.rawValue.replacingOccurrences(of: "{productId}", with: productId!), parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self] (product: ProductWrapper) in
                self?.product = product.product
                print(product.product?.title ?? "")
                print(product.product?.variants?.first??.price ?? "")
                
                completion()
            }, onError: { error in
                print("Error from getProduct function \(error)")
            })
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
                workingData.draftOrder?.lineItems?.append(lineItem)
                return self.network.put(url: NetworkConstants.baseURL, endpoint: endpoint, body: workingData, headers: nil, responseType: DraftOrderWrapper.self)
                
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
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
    
    func fetchDraftOrder(variant : Variant){
        isLoading.accept(true)
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint!, parameters: nil, headers: nil).subscribe {[weak self] (draftOrderWrapper : DraftOrderWrapper) in
            self?.draftOrder = draftOrderWrapper.draftOrder
            //let variant = self?.product?.variants![0]
            self?.updateLineItem(variant: variant)
            
        }.disposed(by: disposeBag)
    }
    
    func updateLineItem(variant : Variant){
        let lineItems = draftOrder?.lineItems
        for lineItem in lineItems ?? [] {
            if lineItem.variantId == variant.id {
                addToCart.onNext(false)
                self.isLoading.accept(false)
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
                    self?.addToCart.onNext(true)
                    self?.isLoading.accept(false)
                    let realmDraftOrder = response?.draftOrder.map { RealmDraftOrder(draftOrder: $0)}
                    // print(realmDraftOrder?.id)
                    self?.realmManger.deleteAllThenAdd(realmDraftOrder!, RealmDraftOrder.self)
                    print(self?.realmManger.getAll(RealmDraftOrder.self).count ?? 0)
                }
                
            }, onError: { error in
                print("Error updating draft order: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func isProductInWishlist(completion: @escaping (Bool) -> Void) {
        let draftOrderId = UserDefaultsManager.shared.getWishListIdFromUserDefaults()
        let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId ?? "")
        _ = network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { (draftOrderWrapper: DraftOrderWrapper) in
                if ((draftOrderWrapper.draftOrder!.lineItems!.contains(where: { $0.title == self.product?.title }))) {
                    completion(true)
                }
                else { completion(false) }
            }, onError: { error in
                print(error)
            })
    }
    
    func removeProduct(completion: @escaping () -> ()) {
        isLoading.accept(true)
        
        guard let draftOrderId = UserDefaultsManager.shared.getWishListIdFromUserDefaults() else { return }
        
        let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)
        
        _ = network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .flatMap { (data: DraftOrderWrapper) -> Observable<(Bool, String?, DraftOrderWrapper?)> in
                var workingData = data
                workingData.draftOrder?.lineItems?.removeAll(where: { lineItem in
                    lineItem.title == self.product?.title
                })
                print("matched items: \(String(describing: workingData.draftOrder?.lineItems?.count))")
                return self.network.put(url: NetworkConstants.baseURL, endpoint: endpoint, body: workingData, headers: nil, responseType: DraftOrderWrapper.self)
            }
            .flatMap { (success, response, updatedDraftOrder) -> Observable<DraftOrderWrapper> in
                if success, let updatedDraftOrder = updatedDraftOrder {
                    return Observable.just(updatedDraftOrder)
                } else {
                    return Observable.error(NSError(domain: "Update failed", code: 0, userInfo: [NSLocalizedDescriptionKey: response ?? "Unknown error"]))
                }
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { updatedDraftOrder in
                self.isLoading.accept(false)
                print("removed and updated")
                completion()
            }, onError: { error in
                print("Error removing product: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
}
