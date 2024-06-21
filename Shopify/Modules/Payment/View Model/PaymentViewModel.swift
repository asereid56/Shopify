//
//  PaymentViewModel.swift
//  Shopify
//
//  Created by Apple on 14/06/2024.
//

import Foundation
import PassKit
import RxCocoa
import RxSwift

protocol PaymentViewModelProtocol{
    var selectedAddress: BehaviorRelay<String?>{get set}
    var primaryAddress: BehaviorRelay<String?>{get set}
    var priceRuleSubject : PublishSubject<(PriceRule?, Error?)>{get}
    var paymentSuccess: PKPaymentAuthorizationStatus { get set }
    var isLoading : BehaviorRelay<Bool>{get}
    func setShippingAddress(address : Address)
    func getSubTotal() -> String
    func loadData() -> Bool
    func startPayment(amount : String) -> PKPaymentRequest
    func handlePaymentAuthorization(_ payment: PKPayment)
    func getPaymentMethod() -> String
    func getSelectedCurrency() -> String
    func placeOrder(financialStatus : String)
    func validateCoupon(coupon : String) 
}

protocol PaymentViewModelDelegate: AnyObject {
    func didFinishPayment(success: Bool)
}


class PaymentViewModel :  PaymentViewModelProtocol{
    private let disposeBag = DisposeBag()
    weak var delegate: PaymentViewModelDelegate?
    private let mockPaymentProcessor: PaymentProcessing
    var paymentSuccess: PKPaymentAuthorizationStatus = .success
    var selectedAddress = BehaviorRelay<String?>(value: "Select Delivery Address")
    var primaryAddress = BehaviorRelay<String?>(value: "Select Delivery Address")
    var priceRuleSubject = PublishSubject<(PriceRule?, Error?)>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    var draftOrder : DraftOrder
    var network : NetworkServiceProtocol
    private let customerId : String
    private let draftOrderId : String
    private var shippingAddress: Address?
    private var billingAddress : Address?
    private let defaults = UserDefaults.standard
    private let realmManager : RealmManagerProtocol
    
    
    init( draftOrder: DraftOrder, network: NetworkServiceProtocol, customerId : String , mockPaymentProcessor : PaymentProcessing , draftOrderId : String, realmManager : RealmManagerProtocol) {
        self.draftOrder = draftOrder
        self.network = network
        self.customerId = customerId
        self.mockPaymentProcessor = mockPaymentProcessor
        self.draftOrderId = draftOrderId
        self.realmManager = realmManager
    }
    
    func loadData() -> Bool{
        isLoading.accept(true)
        let primaryAddressID = defaults.integer(forKey: Constant.PRIMARY_ADDRESS_ID)
        print(primaryAddressID)
        if primaryAddressID == 0{
            return false
        }
        let endpoint = APIEndpoint.editOrDeleteAddress.rawValue.replacingOccurrences(of: "{customer_id}", with: customerId)
            .replacingOccurrences(of: "{address_id}", with: String(primaryAddressID))
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self](addressResponseRoot:AddressResponseRoot) in
                self?.billingAddress = addressResponseRoot.customer_address
                self?.primaryAddress.accept(addressResponseRoot.customer_address.address1)
                self?.isLoading.accept(false)
            }).disposed(by: disposeBag)
        return true
    }
    
    func placeOrder(financialStatus : String){
        isLoading.accept(true)
        //preparing order
        let customer = Customer(id: Int(customerId) ?? 0)
        let order = Order(lineItems: draftOrder.lineItems!, customer: customer, billingAddress: billingAddress!, shippingAddress: ((shippingAddress ?? billingAddress)!) , financialStatus: financialStatus)
        let orderWrapper = OrderWrapper(order: order)
        
        //request
        let endpoint = APIEndpoint.createOrder.rawValue
        network.post(url: NetworkConstants.baseURL, endpoint: endpoint, body: orderWrapper, headers: nil, responseType: OrderWrapper.self).subscribe { [weak self] (success, message , orderWrapper) in
            if success {
                self?.updateDraftOrder()
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func updateDraftOrder(){
        let endpoint = APIEndpoint.getDraftOrder.rawValue.replacingOccurrences(of: "{darft_order_id}", with: draftOrderId)
        if let firstItem = draftOrder.lineItems?.first {
            draftOrder.lineItems = [firstItem]
        }
        let draftOrderWrapper = DraftOrderWrapper(draftOrder: draftOrder)
        network.put(url: NetworkConstants.baseURL, endpoint: endpoint, body: draftOrderWrapper, headers: nil, responseType: DraftOrderWrapper.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self](success, message, response) in
                let realmDraftOrder = response?.draftOrder.map { RealmDraftOrder(draftOrder: $0)}
                self?.realmManager.deleteAllThenAdd(realmDraftOrder!, RealmDraftOrder.self)
                self?.isLoading.accept(false)
            }, onError: { error in
                print("Error updating draft order: \(error)")
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    func setShippingAddress(address : Address){
        if address.default == true {
            billingAddress = address
        }
        shippingAddress = address
    }
    
    func getSubTotal() -> String{
        return draftOrder.subtotalPrice ?? ""
    }
    
    func startPayment(amount : String) -> PKPaymentRequest {
        let request = mockPaymentProcessor.createPaymentRequest(countryCode: shippingAddress?.countryCode ?? "EG", amount: Double(amount) ?? 0.0)
        return request
        
    }
    
    func handlePaymentAuthorization(_ payment: PKPayment) {
        delegate?.didFinishPayment(success: paymentSuccess == .success)
    }
    
    func getPaymentMethod() -> String{
        return defaults.string(forKey: Constant.PAYMENT_METHOD) ?? Constant.APPLE_PAY
    }
    
    func getSelectedCurrency() -> String{
        return defaults.string(forKey: Constant.SELECTED_CURRENCY) ?? Constant.USD
    }
    
    func validateCoupon(coupon : String) {
        let endpoint = APIEndpoint.validateDiscount.rawValue.replacingOccurrences(of: "{discount_code}", with: coupon)
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
            .subscribe(onNext: { [weak self](dicount : DiscountCodeWrapper) in
                guard let priceRuleID  = dicount.discountCode.priceRuleId else{ return}
                self?.getPriceRule(priceRuleID: priceRuleID)
                self?.isLoading.accept(false)
            },onError: { _ in
                self.priceRuleSubject.onNext((nil ,CustomError.invalidCoupon))
            }
            
            ).disposed(by: disposeBag)
    }
    
   private func getPriceRule(priceRuleID : Int) {
        let endpoint = APIEndpoint.priceRule.rawValue.replacingOccurrences(of: "{price_rule_id}", with: String(priceRuleID))
        network.get(url: NetworkConstants.baseURL, endpoint: endpoint, parameters: nil, headers: nil)
           .subscribe(onNext: { [weak self] (priceRuleWrapper : PriceRuleWrapper ) in
               self?.priceRuleSubject.onNext((priceRuleWrapper.priceRule, nil))
            }).disposed(by: disposeBag)
    }
}

enum CustomError: Error {
    case invalidCoupon
}
