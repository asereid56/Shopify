//
//  ShoppingCartViewController.swift
//  Shopify
//
//  Created by Apple on 10/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ShoppingCartViewController: UIViewController , Storyboarded{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var currency: UILabel!
    
    private let disposeBag = DisposeBag()
    var coordinator : MainCoordinator?
    var viewModel : ShoppingCartViewModelProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.delegate = self
        viewModel?.fetchCartItems()
     //   viewModel?.fetchCartItemsFromRealm()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.dataSource = nil
        bindTableView()
    }
    
    private func bindTableView() {
        viewModel?.data
            .map{ data in
                var newData = data
                
                if !newData.isEmpty {
                    newData.removeFirst()
                    self.total.text = CurrencyService.calculatePriceAccordingToCurrency(price: self.viewModel?.getDratOrder().subtotalPrice ?? "-1")
                }
                return newData
            }
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: ShoppingCartTableViewCell.self)){ [weak self](row, model, cell) in
                    let inventoryQuantity = Int((model.properties?[1].value) ?? "-1") ?? 0
                
                cell.setUpCell(model: model)
                                self?.total.text = CurrencyService.calculatePriceAccordingToCurrency(price: self?.viewModel?.getDratOrder().subtotalPrice ?? "-1")
                
    
                cell.deleteAction = {
                    self?.setConfirmationAlert(index: row + 1)
                }
                
                cell.plusBtnTapped
                    .subscribe(onNext: {
                        guard let currentQuantity = Int(cell.productQuantity.text!) else { return }
                        if currentQuantity == 0 || currentQuantity >= Int(0.3 * Double(inventoryQuantity)) {
                            self?.notAvailableAlert(title: "Sold out!")
                        } else {
                            cell.updateQuantity(currentQuantity + 1)
                            self?.viewModel?.plusAction.onNext((row +  1, currentQuantity, inventoryQuantity ))
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.minusBtnTapped
                    .subscribe(onNext: {
                        guard let currentQuantity = Int(cell.productQuantity.text!), currentQuantity > 1 else { return }
                        cell.updateQuantity(currentQuantity - 1)
                        self?.viewModel?.minusAction.onNext((row +  1, currentQuantity))
                    })
                    .disposed(by: cell.disposeBag)
                
                if self?.viewModel?.isSoldOut(inventoryQuantity: inventoryQuantity, productQuantity: Int(model.quantity!)) ?? false{
                    cell.soldOutImage.isHidden = false
                    print(model.variantId)
                }
                
            }
            .disposed(by: disposeBag)
        
        
    }
    
    func setConfirmationAlert(index : Int){
        let alert = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default) { action in self.viewModel?.deleteItem(at: index)
        }
        let btnCancel = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(btnOk)
        alert.addAction(btnCancel)
        self.present(alert, animated: true)
    }
    
    private func notAvailableAlert(title: String){
        let alert = UIAlertController(title: title,
                                      message: "", preferredStyle: .actionSheet)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func btnCheckout(_ sender: Any) {
        if viewModel?.canCheckOut() ?? false{
            coordinator?.goToPayment(draftOrder: (viewModel?.getDratOrder())!)
        }else{
            notAvailableAlert(title: "Oops! Some items in your cart are sold out. Please decrement or remove them.")
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        coordinator?.goBack()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel?.updateRealm()
    }
    
}

extension ShoppingCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let cellHeight = screenHeight * 0.18
        return cellHeight
    }
}
