//
//  ProductInfoViewController.swift
//  Shopify
//
//  Created by Mina on 01/06/2024.
//

import UIKit
import Cosmos
class ProductInfoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var coordinator: MainCoordinator?
    var viewModel: ProductInfoViewModel?
    
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    let images = ["second", "first", "third", "forth"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNib()
        configureScrollView()
        setupScrollView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(page)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getReviews()?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        reviewCell.reviewerImage.image = UIImage(named: viewModel?.getReviews()?[indexPath.row].img ?? "")
        reviewCell.reviewBody.text = viewModel?.getReviews()?[indexPath.row].reviewBody ?? ""
        return reviewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    @IBAction func viewAll(_ sender: Any) {
        coordinator?.goToReviews(vc: self)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        viewModel?.fetchDraftOrder()
    }
    
    @IBAction func addToWishList(_ sender: Any) {
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewCell")
    }
    
    func configureScrollView() {
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
    }
    
    func setupScrollView() {
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
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let scrollViewWidth = scrollView.frame.size.width
        let offset = CGPoint(x: CGFloat(currentPage) * scrollViewWidth, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
}

