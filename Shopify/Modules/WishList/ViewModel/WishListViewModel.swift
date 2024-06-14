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
    let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: "1110462660761")
    let deleteItem: PublishSubject<Int> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init(network: NetworkService) {
        self.network = network
        
        deleteItem
            .withLatestFrom(items) { (index, items) -> (Int, [LineItem]) in
                return (index, items)
            }
            .flatMap { (index, items) -> Observable<(Int, [LineItem], DraftOrderWrapper)> in
                return network.get(endpoint: self.endpoint)
                    .flatMap { (data: DraftOrderWrapper) -> Observable<(Int, [LineItem], DraftOrderWrapper)> in
                        var workingData = data
                        workingData.draftOrder?.lineItems?.remove(at: index)
                        return self.network?.put(endpoint: self.endpoint, body: workingData, responseType: DraftOrderWrapper.self)
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
                },
                onError: { error in
                    print("Error removing item: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        _ = network?.get(endpoint: APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: "1110462660761")).subscribe(onNext: { (data: DraftOrderWrapper) in
            self.items.accept(data.draftOrder?.lineItems ?? [])
            
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("done fetching")
        })
        
        Observable.just(items.value)
            .subscribe(
                
                onNext: { (data: [LineItem]) in
                    self.items.accept(data)
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
