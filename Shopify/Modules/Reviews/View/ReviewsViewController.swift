//
//  ReviewsViewController.swift
//  Shopify.Screens
//
//  Created by Mina on 03/06/2024.
//

import UIKit

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: ReviewsViewModel?
    @IBOutlet weak var reviewsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNib()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.reviews.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewsCell", for: indexPath) as! ReviewTableViewCell
        reviewCell.reviewerImage.image = UIImage(named: viewModel?.reviews[indexPath.row].img ?? "")
        reviewCell.reviewBody.text = viewModel?.reviews[indexPath.row].reviewBody ?? ""
        return reviewCell
    }
    func configureNib() {
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewsCell")
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
    }
}
