//
//  OrderDetailsViewController.swift
//  Shopify
//
//  Created by Aser Eid on 18/06/2024.
//

import UIKit
import Kingfisher

class OrderDetailsViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var createdOnText: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var orderLocation: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var orderDetailsTableView: UITableView!
    
    var coordinator : MainCoordinator?
    var viewModel : OrderDetailsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "OrderDetailsViewCell", bundle: nil)
        orderDetailsTableView.register(nib, forCellReuseIdentifier: "orderDetailsCell")
        
        if let orderIdd = viewModel?.getOrderDetails().id {
            orderId.text = String("\(orderIdd)")
        }
        createdOnText.text = formateTheDate(date: viewModel?.getOrderDetails().createdAt ?? "")
        phoneNum.text = viewModel?.getOrderDetails().shippingAddress?.phone
        orderLocation.text = (viewModel?.getOrderDetails().shippingAddress?.city ?? "") + ", " + (viewModel?.getOrderDetails().shippingAddress?.country ?? "")
        totalPrice.text = CurrencyService.calculatePriceAccordingToCurrency(price: String(viewModel?.getOrderDetails().currentTotalPrice ?? "0"))
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
    
}

extension OrderDetailsViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.getOrderDetails().lineItems?.count ?? 0) - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailsCell", for: indexPath) as! OrderDetailsViewCell
        
        if let lineItems = viewModel?.getOrderDetails().lineItems {
            
            let existProduct = lineItems[indexPath.row + 1]
            
            cell.productImage.kf.setImage(with: URL(string: existProduct.properties?.first?.value ?? "") , placeholder: UIImage(named: "placeholder"))
            cell.productPrice.text = existProduct.price
            cell.productTitle.text = existProduct.title
            cell.productVendor.text = existProduct.vendor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
