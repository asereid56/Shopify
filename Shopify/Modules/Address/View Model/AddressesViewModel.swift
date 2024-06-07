//
//  AddressesViewModel.swift
//  Shopify
//
//  Created by Apple on 05/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol  AddressesViewModelProtocol{
    var data: Driver<[Address]> {get}
    func fetchData()
    func deleteItem(at index: Int) -> Bool
}

class AddressesViewModel : AddressesViewModelProtocol{
    private let disposeBag = DisposeBag()
    private let networkService: NetworkService
    private let customerId : String
    private let dataSubject = BehaviorSubject<[Address]>(value: [])
    
    // Observable that will emit the data
    var data: Driver<[Address]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    
    init(networkService: NetworkService , customerId : String) {
        self.networkService = networkService
        self.customerId = customerId
        //fetchData()
    }
    
     func fetchData() {
         //Endpoint
        let endpoint = APIEndpoint.address.rawValue.replacingOccurrences(of: "{customer_id}", with:customerId )
         //Call
         networkService.get(endpoint: endpoint)
            .subscribe(onNext: {  (data: AddressList) in
                self.dataSubject.onNext(data.addresses!)
            }, onError: { error in
                print("Enter3")
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func deleteItem(at index: Int) -> Bool {
        do {
            var currentAddresses = try dataSubject.value()
            if( currentAddresses[index].default == false){
                deleteAddress(currentAddresses: currentAddresses[index])
//                guard index >= 0 && index < currentAddresses.count else
//                { return }
                currentAddresses.remove(at: index)
                dataSubject.onNext(currentAddresses)
                return true
            }else{
                return false
            }
        } catch {
            print("Error deleting item:", error)
        }
        return false
    }
    
    private func deleteAddress(currentAddresses : Address){
        //Endpoint
        let deleteEndpoint = APIEndpoint.editOrDeleteAddress.rawValue.replacingOccurrences(of: "{customer_id}", with: customerId).replacingOccurrences(of: "{address_id}", with: String(currentAddresses.id!))
        //Call
        networkService.delete(endpoint: deleteEndpoint)
            .subscribe(onNext: {statusCode in
                if statusCode == 200 {
                    print("Deleted Successfully")
                }
            }, onError: { error in
                print("Error deleting item:", error)
            })
            .disposed(by: disposeBag)
    }
    
}
