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
    @IBOutlet weak var screenTitle: UILabel!
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
        setupUI()
        bindViewModel()
        guard let address = viewModel?.address else{return}
        screenTitle.text = "Edit Address"
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
    private func setupUI() {
        country.placeholder = "Select Country"
        city.placeholder = "Select City"
        city.isEnabled = false
    }
    
    private func bindViewModel() {
        viewModel?.selectedCountry
            .map { $0?.name }
            .bind(to: country.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.selectedCity
            .bind(to: city.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.selectedCountry
            .map { $0 != nil }
            .bind(to: city.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
    
    @IBAction func btnCountryTextField(_ sender: Any) {
        coordinator?.goToAddressMeunList(from: self, type: .country, viewModel: viewModel!)
    }
    
    @IBAction func btnCityTextField(_ sender: Any) {
        coordinator?.goToAddressMeunList(from: self, type: .city, viewModel: viewModel!)
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        if (firstName.text?.isEmpty ?? true) ||
            (lastName.text?.isEmpty ?? true) ||
            (country.text?.isEmpty ?? true) ||
            (city.text?.isEmpty ?? true) ||
            (phone.text?.isEmpty ?? true) ||
            (address.text?.isEmpty ?? true) {
            // Handle Validation
            setValidationAlert()
        } else {
            let newAddress = Address(firstName: firstName.text, lastName: lastName.text, address1: address.text,  city: city.text, country: country.text, phone: phone.text, default: isPrimary.isOn)
            if let address = viewModel?.address{
                
                viewModel?.updateAddress(address: newAddress)
                viewModel?.putAddress
                    .subscribe(onNext: { [weak self] (success, message, response) in
                        if success {
                            self?.coordinator?.back()
                        } else {
                            self?.setErrorMessageAlert()
                        }
                    })
                    .disposed(by: disposeBag)
            }else{
                viewModel?.addNewAddress(address: newAddress)
                viewModel?.postAddress
                    .subscribe(onNext: { [weak self] (success, message, response) in
                        if success {
                            self?.coordinator?.back()
                        } else {
                            self?.setErrorMessageAlert()
                        }
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
    
    func setValidationAlert(){
        let alert = UIAlertController(title: "Failed!", message: "All fields are required", preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(btnOk)
        self.present(alert, animated: true)
    }
    
    func setErrorMessageAlert() {
        let alert = UIAlertController(title: "Failed to Add New Address",
         message: "", preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            alert.dismiss(animated: true)
        }
    }
    
}
