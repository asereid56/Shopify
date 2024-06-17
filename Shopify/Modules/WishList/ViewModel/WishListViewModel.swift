//
//  WishListViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
import RxSwift
import RxCocoa
struct Item {}
class WishListViewModel {
    let network: NetworkService?
    let items: BehaviorRelay<[LineItem]> = BehaviorRelay(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let draftOrderId: String?
    let endpoint: String?
    let deleteItem: PublishSubject<Int> = PublishSubject()
    var isEmpty: Observable<Bool> {
        return items.map { $0.isEmpty }
    }
    private let disposeBag = DisposeBag()
    
    init(network: NetworkService) {
        self.network = network
        draftOrderId = UserDefaultsManager.shared.getWishListIdFromUserDefaults()
        endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId ?? "")
        deleteItem
            .withLatestFrom(items) { (index, items) -> (Int, [LineItem]) in
                self.isLoading.accept(true)
                return (index, items)
            }
            .flatMap { (index, items) -> Observable<(Int, [LineItem], DraftOrderWrapper)> in
                return network.get(endpoint: self.endpoint ?? "")
                    .flatMap { (data: DraftOrderWrapper) -> Observable<(Int, [LineItem], DraftOrderWrapper)> in
                        var workingData = data
                        workingData.draftOrder?.lineItems?.remove(at: index+1)
                        return self.network?.put(endpoint: self.endpoint ?? "", body: workingData, responseType: DraftOrderWrapper.self)
                            .map { (success, response, updatedDraftOrder) -> (Int, [LineItem], DraftOrderWrapper) in
                                if success {
                                    return (index, items, updatedDraftOrder ?? workingData)
                                } else {
                                    throw NSError(domain: "Update failed", code: 0, userInfo: [NSLocalizedDescriptionKey: response ?? "Unknown error"])
                                }
                            } ?? Observable.empty()
                    }
            }
            .subscribe(
                onNext: { (index, items, updatedDraftOrder) in
                    var newItems = items
                    newItems.remove(at: index)
                    self.items.accept(newItems)
                    print("Item removed at index: \(index)")
                    self.isLoading.accept(false)
                },
                onError: { error in
                    print("Error removing item: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        isLoading.accept(true)
        _ = network?.get(endpoint: APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId ?? "")).subscribe(onNext: { [weak self] (data: DraftOrderWrapper) in
            var dataExcludingDummy = data.draftOrder?.lineItems
            dataExcludingDummy?.remove(at: 0)
            self?.items.accept(dataExcludingDummy ?? [])
            self?.isLoading.accept(false)
            
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("done fetching")
        })
        
        Observable.just(items.value)
            .subscribe(
                
                onNext: { [weak self] (data: [LineItem]) in
                    self?.items.accept(data)
                },
                
                onError: { error in
                    print(error)
                },
                
                onCompleted: {
                    print("Fetch completed")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func requestDeleteItem(at index: Int) {
        deleteItem.onNext(index)
    }
}
