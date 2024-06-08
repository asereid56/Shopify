//
//  NewAddressViewModel.swift
//  Shopify
//
//  Created by Apple on 07/06/2024.
//

import Foundation
import RxSwift

protocol NewAddressViewModelProtocol{
    var address : Address? {get set}
}

class NewAddressViewModel : NewAddressViewModelProtocol{
    var address: Address?
    private let disposeBag = DisposeBag()
    private let networkService: NetworkService
    private let customerId : String
    
    init(address: Address? = nil, networkService: NetworkService, customerId: String) {
        self.address = address
        self.networkService = networkService
        self.customerId = customerId
    }
    
    
 }
