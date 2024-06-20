//
//  ShoppingCartViewModel.swift
//  Shopify
//
//  Created by Apple on 10/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol ShoppingCartViewModelProtocol {
    var data : Driver<[LineItem]> {get}
    var plusAction : PublishSubject<(Int, Int, Int)> {set get}
    var minusAction : PublishSubject<(Int, Int)>{set get}
    var isLoading : BehaviorRelay<Bool>{get}
    func canCheckOut() -> (Bool, String)
    func getDratOrder() -> DraftOrder
    func fetchCartItems()
    func deleteItem(at index: Int)
    func isSoldOut(inventoryQuantity : Int , productQuantity: Int) -> Bool
    func incrementItem(at row: Int, currentQuantity: Int , inventoryQuantity : Int)
    func decrementItem(at row: Int, currentQuantity: Int)
    func updateRealm()
    func getLineItemsCount() -> Int
    func fetchCartItemsFromRealm()
}

class ShoppingCartViewModel: ShoppingCartViewModelProtocol{
    private let disposeBag = DisposeBag()
    private let dataSubject = BehaviorSubject<[LineItem]>(value: [])
    private let networkService: NetworkServiceProtocol
    private let realmManager : RealmManagerProtocol
    private let draftOrderId : String
    private var endpoint : String?
    private var draftOrderWrapper:DraftOrderWrapper = DraftOrderWrapper()
    private var lineItems : [LineItem]?
    var data: Driver<[LineItem]>{
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    var plusAction = PublishSubject<(Int, Int, Int)>()
    var minusAction = PublishSubject<(Int, Int)>()
    
    init(networkService: NetworkServiceProtocol, draftOrderId: String , realmManager : RealmManagerProtocol) {
        self.networkService = networkService
        self.draftOrderId = draftOrderId
        self.realmManager = realmManager
        endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)
        setupBindings()
    }
    
    private func setupBindings() {
        plusAction
            .debounce(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] row, currentQuantity , inventoryQuantity in
                self?.incrementItem(at: row, currentQuantity: currentQuantity , inventoryQuantity: inventoryQuantity)
            })
            .disposed(by: disposeBag)
        
        minusAction
            .debounce(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] row, currentQuantity in
                self?.decrementItem(at: row, currentQuantity: currentQuantity)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCartItemsFromRealm()  {
        isLoading.accept(true)
        let realmDraftOrders = realmManager.getAll(RealmDraftOrder.self)
        print(realmDraftOrders.count)
        let draftOrder = DraftOrder(from: realmDraftOrders.first!)
        draftOrderWrapper.draftOrder = draftOrder
         dataSubject.onNext(draftOrder.lineItems!)
//        guard let lineItems = draftOrder.lineItems else{return}
//        dataSubject.onNext(lineItems)
        isLoading.accept(false)
        
    }
    
    func fetchCartItems() {
        isLoading.accept(true)
        networkService.get(url: NetworkConstants.baseURL, endpoint: endpoint ?? "", parameters: nil, headers: nil)
            .flatMap { (draftOrderWrapper: DraftOrderWrapper) -> Observable<[LineItem]> in
                self.draftOrderWrapper = draftOrderWrapper
                let lineItems = draftOrderWrapper.draftOrder?.lineItems ?? []
                return Observable.just(lineItems)
            }
            .flatMap { lineItems -> Observable<[LineItem]> in
                Observable.create { observer in
                    var mutableLineItems = lineItems
                    let observables = mutableLineItems.map { lineItem -> Observable<Void> in
                        let endpoint = APIEndpoint.productVariant.rawValue.replacingOccurrences(of: "{variant_id}", with: String(lineItem.variantId ?? 0))
                        return self.networkService.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
                            .flatMap { (variantWrapper: VariantWrapper) -> Observable<Void> in
                                Observable.create { observer in
                                    let quantity = variantWrapper.variant?.inventoryQuantity
                                    if let quantity = quantity {
                                        for i in 0..<mutableLineItems.count {
                                            if mutableLineItems[i].variantId == variantWrapper.variant?.id {
                                                let property = Property(name: "quantity", value: String(quantity))
                                                if mutableLineItems[i].properties != nil {
                                                    if mutableLineItems[i].properties?.count == 2{
                                                        mutableLineItems[i].properties?.remove(at: 1)
                                                    }
                                                    
                                                    mutableLineItems[i].properties?.append(property)
                                                } else {
                                                    mutableLineItems[i].properties = [property]
                                                }
                                                break
                                            }
                                        }
                                    }
                                    observer.onNext(())
                                    observer.onCompleted()
                                    return Disposables.create()
                                }
                            }
                            .catchErrorJustReturn(())
                    }
                    
                    Observable.zip(observables).subscribe(onNext: { _ in
                        
                        observer.onNext(mutableLineItems)
                        observer.onCompleted()
                    }).disposed(by: self.disposeBag)
                    
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { [weak self] updatedLineItems in
                self?.lineItems = updatedLineItems
                self?.isLoading.accept(false)
                self?.dataSubject.onNext(updatedLineItems)
            }, onError: { error in
                self.isLoading.accept(false)
                print("Error fetching and processing cart items: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func isSoldOut(inventoryQuantity : Int , productQuantity: Int) -> Bool{
        if  productQuantity > max(1, Int(0.3 * Double(inventoryQuantity))){
            return true
        }
        return false
    }
    
    func incrementItem(at row: Int, currentQuantity: Int , inventoryQuantity : Int) {
        if currentQuantity < Int(0.3 * Double(inventoryQuantity)) && currentQuantity > 0{
            do {
                var currentProduct = try dataSubject.value()
                currentProduct[row].quantity = currentQuantity + 1
                updateDraftOrder(lineItems: currentProduct)
            } catch {
                print("Error deleting item:", error)
            }
        }
    }
    
    func decrementItem(at row: Int, currentQuantity: Int) {
        if currentQuantity  > 1{
            do {
                var currentProduct = try dataSubject.value()
                currentProduct[row].quantity = currentQuantity - 1
                updateDraftOrder(lineItems: currentProduct)
            } catch {
                print("Error deleting item:", error)
            }
        }
    }
    
    
    func deleteItem(at index: Int){
        do {
            var currentProduct = try dataSubject.value()
            guard index >= 0 && index < currentProduct.count else
            { return }
            currentProduct.remove(at: index)
            updateDraftOrder(lineItems: currentProduct)
        } catch {
            print("Error deleting item:", error)
        }
    }
    
    private  func updateDraftOrder(lineItems: [LineItem]) {
        isLoading.accept(true)
        let draftOrder = DraftOrder(lineItems: lineItems)
        let draftOrderWrapper = DraftOrderWrapper(draftOrder: draftOrder)
        
        networkService.put(url: NetworkConstants.baseURL, endpoint: endpoint ?? "", body: draftOrderWrapper, headers: nil, responseType: DraftOrderWrapper.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] (success, message, response) in
                guard let self = self, let response = response else { return }
                self.draftOrderWrapper = response
                if let lineItems = response.draftOrder?.lineItems {
                    self.lineItems = lineItems
                    isLoading.accept(false)
                    self.dataSubject.onNext(lineItems)
                }
            }, onError: { error in
                print("Error updating draft order: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    
    func getDratOrder() -> DraftOrder{
        return (draftOrderWrapper.draftOrder)!
    }
    
    func canCheckOut() -> (Bool, String){
        if lineItems!.count <= 1 {
            return (false,"Shopping cart is empty!")
        }
        for index in 1..<lineItems!.count{
            if lineItems![index].quantity! >  max(1 , Int(0.3 * Double(lineItems![index].properties![1].value ?? "")!)){
                return (false,"Oops! Some items in your cart are sold out. Please decrement or remove them.")
            }
        }
        return (true , "")
    }
    
    func updateRealm() {
        let realmDraftOrder = draftOrderWrapper.draftOrder.map { RealmDraftOrder(draftOrder: $0)}
        realmManager.deleteAllThenAdd(realmDraftOrder!, RealmDraftOrder.self)
    }
    
    func getLineItemsCount() -> Int{
        return lineItems?.count ?? 0
    }
}

