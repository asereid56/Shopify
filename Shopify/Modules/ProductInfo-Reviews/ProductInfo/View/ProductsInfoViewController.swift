//
//  ProductInfoViewController.swift
//  Shopify
//
//  Created by Mina on 01/06/2024.
//

import UIKit

class ProductInfoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    let reviewText = "Lorem ipsum dolor sit amet, consectetur ire adipiscing elit. Pellentesque malesuada eget vitae amet."
    
    
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    let images = ["second", "first", "third", "forth"]
    var reviews = [Review]()
    override func viewDidLoad() {
        super.viewDidLoad()
        reviews = [Review(img: "1st", reviewBody: reviewText),
                   Review(img: "2nd", reviewBody: reviewText),
                   Review(img: "3rd", reviewBody: reviewText)]
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewCell")
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height+680)
        reviewsTableView.frame.size.height = 420
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        pageControl.numberOfPages = images.count
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
        setup()
    }
    
    func setup() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollViewWidth = scrollView.frame.size.width
        let scrollViewHeight = scrollView.frame.size.height
        
        for i in 0..<images.count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage(named: images[i])
            let xPosition = CGFloat(i) * scrollViewWidth
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(images.count), height: scrollViewHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(page)
    }
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let scrollViewWidth = scrollView.frame.size.width
        let offset = CGPoint(x: CGFloat(currentPage) * scrollViewWidth, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        reviewCell.reviewerImage.image = UIImage(named: reviews[indexPath.row].img ?? "")
        reviewCell.reviewBody.text = reviews[indexPath.row].reviewBody ?? ""
        return reviewCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    @IBAction func viewAll(_ sender: Any) {
        let reviewsVC = self.storyboard?.instantiateViewController(withIdentifier: "reviews") as! ReviewsViewController
        self.present(reviewsVC, animated: true)
    }
}

