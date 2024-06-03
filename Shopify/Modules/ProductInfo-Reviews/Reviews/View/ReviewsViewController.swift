//
//  ReviewsViewController.swift
//  Shopify.Screens
//
//  Created by Mina on 03/06/2024.
//

import UIKit

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    var reviews = [Review]()
    @IBOutlet weak var reviewsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "1st", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewsCell")
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewsCell", for: indexPath) as! ReviewTableViewCell
        reviewCell.reviewerImage.image = UIImage(named: reviews[indexPath.row].img ?? "")
        reviewCell.reviewBody.text = reviews[indexPath.row].reviewBody ?? ""
        return reviewCell
    }

}
