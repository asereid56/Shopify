//
//  MenuListViewController.swift
//  Shopify
//
//  Created by Apple on 08/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol MenuListViewControllerDelegate: AnyObject {
    func didSelectCountry(_ country: Country)
    func didSelectCity(_ city: String)
}

enum ListType {
    case country
    case city
}

class MenuListViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    var viewModel: NewAddressViewModelProtocol?
    var type: ListType?
    weak var delegate: MenuListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.dataSource = nil
        bindViewModel()
    }
    
    private func bindViewModel() {
        switch type {
        case .country:
            screenTitle.text = "Countries"
            viewModel?.countries
                .bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, country, cell in
                    cell.textLabel?.text = country.name
                }
                .disposed(by: disposeBag)
            
            tableView.rx.modelSelected(Country.self)
                .subscribe(onNext: { [weak self] country in
                    self?.delegate?.didSelectCountry(country)
                    self?.dismiss(animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
            
        case .city:
            screenTitle.text = "Cities"
            viewModel?.cities
                .bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, city, cell in
                    cell.textLabel?.text = city
                }
                .disposed(by: disposeBag)
            
            tableView.rx.modelSelected(String.self)
                .subscribe(onNext: { [weak self] city in
                    self?.delegate?.didSelectCity(city)
                    self?.dismiss(animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
        case .none:
            return
        }
    }
}
