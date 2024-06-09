//
//  AddressesViewController.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class AddressesViewController: UIViewController ,Storyboarded {
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var viewModel: AddressesViewModelProtocol?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.delegate = self
        setUpSelectTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.dataSource = nil
        viewModel?.fetchData()
        bindTableView()
    }
    
    @IBAction func goToNewAddress(_ sender: Any) {
        coordinator?.goToNewAddress()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.back()
    }
    
    private func bindTableView() {
        // Bind the data to the table view
        viewModel!.data
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: AddressesTableViewCell.self)) { (row, model, cell) in
                print(model.address1!)
                cell.address.text = model.address1
                if row == 0 {
                    cell.checkMark.isHidden = false
                } else {
                    cell.checkMark.isHidden = true

                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.setConfirmationAlert(indexPath: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpSelectTableViewCell() {
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                print("Selected row: \(indexPath.row)")
                do {
                    let selectedItem: Address = try self.tableView.rx.model(at: indexPath)
                    coordinator?.goToEditAddress(address: selectedItem)
                } catch {
                    print("Error getting model at \(indexPath): \(error)")
                }
            }).disposed(by: disposeBag)
        
    }
    
    func setConfirmationAlert(indexPath : IndexPath){
        let alert = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default) { action in
            let isDeleted = self.viewModel?.deleteItem(at: indexPath.row)
            if isDeleted == false {
                let alert = UIAlertController(title: "Can't Delete Default Address",
                 message: "", preferredStyle: .actionSheet)
                self.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
                    alert.dismiss(animated: true)
                }
            }
        }
        let btnCancel = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(btnOk)
        alert.addAction(btnCancel)
        self.present(alert, animated: true)
    }
                
}

extension AddressesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let cellHeight = screenHeight * 0.1
        return cellHeight
    }
}
