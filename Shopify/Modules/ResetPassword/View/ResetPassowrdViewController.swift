//
//  ResetPassowrdViewController.swift
//  Shopify
//
//  Created by Mina on 21/06/2024.
//

import UIKit

class ResetPassowrdViewController: UIViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var email: UITextField!
    var viewModel: ResetPasswordViewModel?
    var coordinator: MainCoordinator?
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func resetPassword(_ sender: Any) {
        if checkInternetAndShowToast(vc: self) {
            loadingIndicator.isHidden = false
            viewModel?.resetPassword(with: email.text!) {
                self.image.isHidden = false
                self.text.isHidden = false
                self.loadingIndicator.isHidden = true
            }
        }
    }
  
    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
    
}
