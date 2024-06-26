//
//  PaymentMethodViewController.swift
//  Shopify
//
//  Created by Apple on 15/06/2024.
//

import UIKit

protocol PaymentMethodViewControllerDelegate: AnyObject {
    func selectedMethod()
}

class PaymentMethodViewController:UIViewController, UISheetPresentationControllerDelegate,Storyboarded {
    
    @IBOutlet weak var applePayCheckMark: UIImageView!
    @IBOutlet weak var codCheckMark: UIImageView!
    
    var viewModel : PaymentMethodViewModelProtocol?
    weak var delegate: PaymentMethodViewControllerDelegate?
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sheetPresentationController.delegate = self
        sheetPresentationController.selectedDetentIdentifier = .medium
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.detents = [
            .medium()
            
        ]
        
        switch viewModel?.getPaymentMethod() {
        case Constant.COD:
            applePayCheckMark.isHidden = true
            codCheckMark.isHidden = false
        default:
            applePayCheckMark.isHidden = false
            codCheckMark.isHidden = true
        }
        
        
    }
    
    @IBAction func btnApplePay(_ sender: Any) {
        viewModel?.setPaymentMethod(method: Constant.APPLE_PAY)
        delegate?.selectedMethod()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCOD(_ sender: Any) {
        viewModel?.setPaymentMethod(method: Constant.COD)
        delegate?.selectedMethod()
        self.dismiss(animated: true, completion: nil)
    }
    
}
