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
    private let phoneRegex = "^\\(?(\\d{3})\\)?[- ]?(\\d{4})[- ]?(\\d{4})$"
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
            isPrimary.isEnabled = false
        }else{
            isPrimary.isOn = false
        }
        
    }
    private func setupUI() {
        firstName.text = UserDefaultsManager.shared.getFirstNameFromUserDefaults()
        lastName.text = UserDefaultsManager.shared.getLastNameFromUserDefaults()
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
        coordinator?.goBack()
    }
    
    @IBAction func btnCountryTextField(_ sender: Any) {
        coordinator?.goToAddressMeunList(from: self, type: .country, viewModel: viewModel!)
    }
    
    @IBAction func btnCityTextField(_ sender: Any) {
        coordinator?.goToAddressMeunList(from: self, type: .city, viewModel: viewModel!)
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        if checkInternetAndShowToast(vc: self) {
            if (firstName.text?.isEmpty ?? true) ||
                (lastName.text?.isEmpty ?? true) ||
                (country.text?.isEmpty ?? true) ||
                (city.text?.isEmpty ?? true) ||
                (phone.text?.isEmpty ?? true) ||
                (address.text?.isEmpty ?? true) {
                // Handle Validation
                setValidationAlert(message: "All fields are required")
            }else if !validatePhoneNumber(phoneNumber: phone.text ?? ""){
                setValidationAlert(message: "Invalid phone number")
            }
            else {
                let newAddress = Address(firstName: firstName.text, lastName: lastName.text, address1: address.text,  city: city.text, country: country.text, phone: phone.text, default: isPrimary.isOn)
                if (viewModel?.address) != nil{
                    
                    viewModel?.updateAddress(address: newAddress)
                    viewModel?.putAddress
                        .subscribe(onNext: { [weak self] (success, message, response) in
                            if success {
                                self?.coordinator?.goBack()
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
                                self?.coordinator?.goBack()
                            } else {
                                self?.setErrorMessageAlert()
                            }
                        })
                        .disposed(by: disposeBag)
                }
            }
        }
    }
    
    private func setValidationAlert(message : String){
        let alert = UIAlertController(title: "Failed!", message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(btnOk)
        self.present(alert, animated: true)
    }
    
    private func setErrorMessageAlert() {
        let alert = UIAlertController(title: "Failed to Add New Address",
                                      message: "", preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            alert.dismiss(animated: true)
        }
    }
    
    private func validatePhoneNumber(phoneNumber: String) -> Bool {
        let phoneValidation = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneValidation.evaluate(with: phoneNumber)
    }
    
}

extension NewAddressViewController : MenuListViewControllerDelegate{
    func didSelectCountry(_ country: Country) {
        viewModel?.selectedCountry.accept(country)
        viewModel?.selectedCity.accept(nil)
    }
    
    func didSelectCity(_ city: String) {
        viewModel?.selectedCity.accept(city)
    }
}
