//
//  NewAddressViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class NewAddressViewController: UIViewController ,Storyboarded {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var isPrimary: UISwitch!
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var viewModel: NewAddressViewModelProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        guard let address = viewModel?.address else{return}
        setAddress(address: address)
    }
    
    func setAddress(address : Address) {
        firstName.text = address.firstName
        lastName.text = address.lastName
        country.text = address.country
        city.text = address.city
        phone.text = address.phone
        self.address.text = address.address1
        if address.default == true {
            isPrimary.isOn = true
        }else{
            isPrimary.isOn = false
        }
        
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
}
