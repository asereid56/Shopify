//
//  PaymentViewController.swift
//  Shopify
//
//  Created by Apple on 14/06/2024.
//

import UIKit
import PassKit
import RxSwift
import RxCocoa

class PaymentViewController: UIViewController, Storyboarded {
    var viewModel : PaymentViewModelProtocol?
    var coordinator : MainCoordinator?
    private let disposeBag = DisposeBag()
    private var totalPrice = ""
    
    @IBOutlet weak var shippingAddress: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var paymentMethodImage: UIImageView!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var deliveryCharge: UILabel!
    @IBOutlet weak var dicount: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var validateCoupon: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        if viewModel?.loadData() == true{
            viewModel?.primaryAddress.bind(to: shippingAddress.rx.text).disposed(by: disposeBag)
        }else{
            shippingAddress.text = "Select Delivery Address"
        }
    }
    
    private func setUpUI(){
        subTotal.text = CurrencyService.calculatePriceAccordingToCurrency(price: (viewModel?.getSubTotal())!)
        deliveryCharge.text =  CurrencyService.calculatePriceAccordingToCurrency(price: "10")
        totalPrice = String(Double((viewModel?.getSubTotal())!)!  +  10.00)
        total.text =  CurrencyService.calculatePriceAccordingToCurrency(price: totalPrice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpSelectedAddress()
        setUpSelectedPaymentMethod()
    }
    
    
    
    private func setUpSelectedAddress(){
        let _ = viewModel?.loadData()
        viewModel?.selectedAddress.bind(to: shippingAddress.rx.text).disposed(by: disposeBag)
    }
    
    private func setUpSelectedPaymentMethod(){
        paymentMethod.text = viewModel?.getPaymentMethod()
        switch  viewModel?.getPaymentMethod(){
        case Constant.COD:
            paymentMethodImage.image = UIImage(named: "pay")
        default:
            paymentMethodImage.image = UIImage(named: "applePay")
        }
    }
    
    @IBAction func btnDeliveryAddress(_ sender: Any) {
        coordinator?.goToAddresses(from: self, source: "payment")
    }
    
    
    @IBAction func btnPaymentMethod(_ sender: Any) {
        coordinator?.goToPaymentMethd(from: self)
        
    }
    
    @IBAction func btnConfirmPayment(_ sender: Any) {
        switch  viewModel?.getPaymentMethod(){
        case Constant.COD:
            if canPayUsingCOD() == true {
                print("success")
                viewModel?.placeOrder(financialStatus: Constant.PENDING)
                coordinator?.goToOrderConfirmed()
            }
        default:
            payUsingApplePay()
        }
    }
    
    private func payUsingApplePay(){
        let request = viewModel?.startPayment(amount: totalPrice)
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: request!.supportedNetworks) else {
            showError(title: "Can't make payments with Apple Pay")
            return
        }
        if let paymentController = PKPaymentAuthorizationViewController(paymentRequest: request!) {
            paymentController.delegate = self
            present(paymentController, animated: true, completion: nil)
        }
    }
    
    private func canPayUsingCOD() -> Bool{
        if Double(totalPrice)! > 10000.00 && viewModel?.getSelectedCurrency() == Constant.EGP{
            showError(title: "Cash on Delivery is not available for orders exceeding certain amount. Please select a different payment method.")
            return false
        } else if  Double(totalPrice)! > 300.00 && viewModel?.getSelectedCurrency() == Constant.USD{
            showError(title: "Cash on Delivery is not available for orders exceeding certain amount. Please select a different payment method.")
            return false
        }
      return true
    }
    
    private func showError(title: String){
        let alert = UIAlertController(title: title,
                                      message: "", preferredStyle: .actionSheet)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.goBack()
    }
    
}

extension PaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        viewModel?.handlePaymentAuthorization(payment)
        let status: PKPaymentAuthorizationStatus = viewModel?.paymentSuccess ?? .failure
        let result = PKPaymentAuthorizationResult(status: status, errors: nil)
        completion(result)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension PaymentViewController: PaymentViewModelDelegate {
    func didFinishPayment(success: Bool) {
        if success {
            print("Payment successful!")
            viewModel?.placeOrder(financialStatus: Constant.PAID)
            coordinator?.goToOrderConfirmed()
        } else {
            showError(title: "Payment failed!" )
        }
    }
}

extension PaymentViewController : AddressesViewControllerDelegate{
    func didSelectAddress(_ address: Address) {
        viewModel?.selectedAddress.accept(address.address1)
        viewModel?.setShippingAddress(address: address)
    }
}

extension PaymentViewController : PaymentMethodViewControllerDelegate{
    func selectedMethod() {
        setUpSelectedPaymentMethod()
    }
}