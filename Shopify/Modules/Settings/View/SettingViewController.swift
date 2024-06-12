//
//  SettingViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit
import RxSwift

class SettingViewController: UIViewController, Storyboarded {
    var coordinator : MainCoordinator?
    //let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
//        let network = NetworkService()
//        let customer = Customer(firstName: "Hassan", lastName: "Ali" , email: "m11101hosam@gmail.com" , note: "111111,23423")
//        let customerResponse = CustomerResponse(customer: customer)
//        let endpoint = APIEndpoint.createCustomer.rawValue
//        network.post(endpoint: endpoint, body: customerResponse, responseType: CustomerResponse.self)
//            .subscribe(onNext: { success, message, response in
//                if success {
//                    print("Request succeeded: \(message ?? "")")
//                    if let response = response {
//                        print("Response: \(response)")
//                    }
//                } else {
//                    print("Request failed: \(message ?? "")")
//                }
//            }, onError: { error in
//                print("Request error: \(error)")
//            })
//            .disposed(by: disposeBag)
    }
    
    @IBAction func goToAddresses(_ sender: Any) {
        coordinator?.goToAddresses()
    }
    
    
    @IBAction func goToContactUs(_ sender: Any) {
        coordinator?.goToContactUs()
    }
    
    @IBAction func goToAboutUs(_ sender: Any) {
        coordinator?.goToAboutUs()
    }
}
