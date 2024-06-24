//
//  OrdersScreenViewController.swift
//  Shopify
//
//  Created by Aser Eid on 17/06/2024.
//

import UIKit

class OrdersScreenViewController: UIViewController , Storyboarded {
    
    
    @IBOutlet weak var ordersTable: UITableView!
    
    var coordinator : MainCoordinator?
    var viewModel : OrdersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "OrdrersTableViewCell", bundle: nil)
        ordersTable.register(nib, forCellReuseIdentifier: "orderCell")
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
}

extension OrdersScreenViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getOrders().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let existOrder : Order = (viewModel?.getOrders()[indexPath.row])!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrdrersTableViewCell
        
        if let orderId = existOrder.id {
            cell.orderId.text = String( "\(orderId)")
        }
        cell.createdAt.text = formateTheDate(date: existOrder.createdAt ?? "")
        cell.orderPlace.text = (existOrder.shippingAddress?.city ?? "") + ", " + (existOrder.shippingAddress?.country ?? "")
        cell.totalPrice.text = CurrencyService.calculatePriceAccordingToCurrency(price: String(
            ( Double (existOrder.currentSubtotalPrice ?? "0" )! + 10 )
        ))
        cell.phoneNum.text = existOrder.shippingAddress?.phone
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedOrder = viewModel?.getOrders()[indexPath.row] {
            coordinator?.gotoOrderDetailsScreen(order: selectedOrder)
        }
    }
    
}
