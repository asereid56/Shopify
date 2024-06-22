//
//  ReviewsViewController.swift
//  Shopify.Screens
//
//  Created by Mina on 03/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
class ReviewsViewController: UIViewController  {
    var viewModel: ReviewsViewModel?
    let disposeBag = DisposeBag()
    @IBOutlet weak var reviewsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindTableView()
        getReviews()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewsCell")
    }
    
    func bindTableView() {
        viewModel?.reviewsData.bind(to: reviewsTableView.rx.items(cellIdentifier: "reviewsCell", cellType: ReviewTableViewCell.self)) { index, item, cell in
            
            cell.configure(item: item)
        }.disposed(by: disposeBag)
    }
    
    func getReviews() {
        viewModel?.getReviews()
    }
}
