//
//  NewAddressViewModel.swift
//  Shopify
//
//  Created by Apple on 07/06/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol NewAddressViewModelProtocol{
    var address : Address? {get set}
    var countries : BehaviorRelay<[Country]> {get set}
    var selectedCountry : BehaviorRelay<Country?>{get set}
    var selectedCity : BehaviorRelay<String?>{get set}
    var cities  :  BehaviorRelay<[String]>{get set}
    var postAddress: PublishSubject<(Bool, String?, AddressResponseRoot?)> {get}
    var putAddress: PublishSubject<(Bool, String?, AddressResponseRoot?)> {get}
    func addNewAddress(address: Address)
    func updateAddress(address: Address)
}

class NewAddressViewModel : NewAddressViewModelProtocol{
    
    var postAddress: PublishSubject<(Bool, String?, AddressResponseRoot?)> = PublishSubject()
    var putAddress: PublishSubject<(Bool, String?, AddressResponseRoot?)> = PublishSubject()
    
    var address: Address?
    private let disposeBag = DisposeBag()
    private let networkService: NetworkServiceProtocol
    private let customerId : String
    
    var countries = BehaviorRelay<[Country]>(value: [])
    var selectedCountry = BehaviorRelay<Country?>(value: nil)
    var selectedCity = BehaviorRelay<String?>(value: nil)
    var cities = BehaviorRelay<[String]>(value: [])
    
    init(address: Address? = nil, networkService: NetworkServiceProtocol, customerId: String, dataLoader: DataLoader) {
        self.address = address
        self.networkService = networkService
        self.customerId = customerId
        loadData(dataLoader: dataLoader)
    }
    
    private func loadData(dataLoader: DataLoader){
        dataLoader.loadCountries()
            .observeOn( MainScheduler.instance)
            .subscribe(onNext: { [weak self] countries in
                self?.countries.accept(countries.countries)
            })
            .disposed(by: disposeBag)
        selectedCountry
            .map { $0?.cities ?? [] }
            .bind(to: cities)
            .disposed(by: disposeBag)
    }
    
    func addNewAddress(address: Address) {
        let endpoint = APIEndpoint.address.rawValue.replacingOccurrences(of: "{customer_id}", with: customerId)
        let addressRequest = AddressRequestRoot(address: address)
        networkService.post(url: NetworkConstants.baseURL ,endpoint: endpoint, body: addressRequest, headers: nil, responseType: AddressResponseRoot.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] (success, message, response) in
                self?.postAddress.onNext((success, message, response))
            })
            .disposed(by: disposeBag)
    }
    
    func updateAddress(address: Address) {
        let endpoint = APIEndpoint.editOrDeleteAddress.rawValue.replacingOccurrences(of: "{customer_id}", with: customerId).replacingOccurrences(of: "{address_id}", with: String(self.address?.id ?? 0))
        let addressRequest = AddressRequestRoot(address: address)
        networkService.put(url: NetworkConstants.baseURL ,endpoint: endpoint, body: addressRequest, headers: nil, responseType: AddressResponseRoot.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] (success, message, response) in
                self?.putAddress.onNext((success, message, response))
            })
            .disposed(by: disposeBag)
        }
    
    
 }


