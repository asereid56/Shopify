//
//  ReviewsViewController.swift
//  Shopify.Screens
//
//  Created by Mina on 03/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
class ReviewsViewController: UIViewController , Storyboarded{
  
    @IBOutlet weak var reviewsTableView: UITableView!
    
    var viewModel: ReviewsViewModel?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNib()
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
