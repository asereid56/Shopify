//
//  OnBoardingThreeViewController.swift
//  Shopify
//
//  Created by Aser Eid on 14/06/2024.
//

import UIKit

class OnBoardingThreeViewController: UIViewController , Storyboarded{

    var coordinator : MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
    }
    

    @IBAction func getStartedBtn(_ sender: Any) {
        coordinator?.gotoTab()
    }
    

}
