//
//  ShoppingCartTableViewCell.swift
//  Shopify
//
//  Created by Apple on 10/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class ShoppingCartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var soldOutImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productVendor: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var btnMinus: UIImageView!
    @IBOutlet weak var btnPlus: UIImageView!
    @IBOutlet weak var btnDelete: UIImageView!
    @IBOutlet weak var options: UILabel!
    
    var disposeBag = DisposeBag()
    var plusBtnTapped = PublishSubject<Void>()
    var minusBtnTapped = PublishSubject<Void>()
    
    var plusAction: (() -> Void)?
    var minusAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let plusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(plusButtonTapped))
        btnPlus.addGestureRecognizer(plusTapGestureRecognizer)
        
        let minusTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(minusButtonTapped))
        btnMinus.addGestureRecognizer(minusTapGestureRecognizer)
        
        let deleteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteButtonTapped))
        btnDelete.addGestureRecognizer(deleteTapGestureRecognizer)
        
        btnPlus.isUserInteractionEnabled = true
        btnMinus.isUserInteractionEnabled = true
        btnDelete.isUserInteractionEnabled = true
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag() // Reset dispose bag for cell reuse
    }
    
    func setUpCell(model : LineItem){
        let url  = URL(string: (model.properties?.first?.value)!)
        productTitle.text = model.title
        options.text = model.properties![1].value
        productVendor.text = model.vendor
        productPrice.text = CurrencyService.calculatePriceAccordingToCurrency(price: model.price ?? "0.0")
        productQuantity.text = String(model.quantity ?? 0)
        productImage.kf.setImage(with: url)
        soldOutImage.isHidden = true
    }
    
    @objc private func plusButtonTapped() {
        plusBtnTapped.onNext(())
    }
    
    @objc private func minusButtonTapped() {
        minusBtnTapped.onNext(())
    }
    
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    func updateQuantity(_ quantity: Int) {
        productQuantity.text = String(quantity)
    }
    
}
