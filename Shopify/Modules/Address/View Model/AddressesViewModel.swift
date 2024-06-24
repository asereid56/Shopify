//
//  AddressesViewModel.swift
//  Shopify
//
//  Created by Apple on 07/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol  AddressesViewModelProtocol{
    var data: Driver<[Address]> {get}
    var isLoading : BehaviorRelay<Bool>{get}
    func fetchData()
    func deleteItem(at index: Int) -> Bool
    func setPrimaryAddress(defaultAddressID : Int)
    func getAddressesCount() -> Int
}

class AddressesViewModel : AddressesViewModelProtocol{
    
    private let disposeBag = DisposeBag()
    private let networkService: NetworkServiceProtocol
    private let customerId : String
    private let dataSubject = BehaviorSubject<[Address]>(value: [])
    private let defualts = UserDefaults.standard
    private var addressesCount = 0
    // Observable that will emit the data
    var data: Driver<[Address]> {
        return dataSubject.asDriver(onErrorJustReturn: [])
    }
    var isLoading = BehaviorRelay<Bool>(value: true)
    
    init(networkService: NetworkServiceProtocol , customerId : String) {
        self.networkService = networkService
        self.customerId = customerId
        //fetchData()
    }
    
    func fetchData() {
        isLoading.accept(true)
        //Endpoint
        let endpoint = APIEndpoint.address.rawValue.replacingOccurrences(of: "{customer_id}", with:customerId )
        //Call
        networkService.get(url: NetworkConstants.baseURL,endpoint: endpoint, parameters: nil, headers: nil)
            .map { (addressList: AddressList) -> [Address] in
                var addresses = addressList.addresses ?? []
                if let defaultIndex = addresses.firstIndex(where: { $0.default == true }) {
                    let defaultAddress = addresses.remove(at: defaultIndex)
                    addresses.insert(defaultAddress, at: 0)
                }
                return addresses
            }
            .subscribe(onNext: { [weak self] addresses in
                self?.addressesCount = addresses.count
                self?.isLoading.accept(false)
                self?.dataSubject.onNext(addresses)
            }, onError: { error in
                print("Error fetching addresses: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func deleteItem(at index: Int) -> Bool {
        do {
            isLoading.accept(true)
            var currentAddresses = try dataSubject.value()
            if( currentAddresses[index].default == false){
                deleteAddress(currentAddresses: currentAddresses[index])
                currentAddresses.remove(at: index)
                dataSubject.onNext(currentAddresses)
                isLoading.accept(false)
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
        networkService.delete(url: NetworkConstants.baseURL ,endpoint: deleteEndpoint, parameters: nil, headers: nil)
            .subscribe(onNext: {statusCode in
                if statusCode == 200 {
                    print("Deleted Successfully")
                }
            }, onError: { error in
                print("Error deleting item:", error)
            })
            .disposed(by: disposeBag)
    }
    
    func setPrimaryAddress(defaultAddressID : Int){
        defualts.set(defaultAddressID, forKey: Constant.PRIMARY_ADDRESS_ID)
    }
    
    func getAddressesCount() -> Int{
        return addressesCount
    }
    
}

