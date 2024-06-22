//
//  ProductInfoViewController.swift
//  Shopify
//
//  Created by Mina on 01/06/2024.
//

import UIKit
import Cosmos
import RxSwift
class ProductInfoViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var coordinator: MainCoordinator?
    var viewModel: ProductInfoViewModel?
    let disposeBag = DisposeBag()
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var descriptionTxt: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    let images = ["second", "first", "third", "forth"]
    var imgs: [ProductImage?]?
    override func viewDidLoad() {
        super.viewDidLoad()
        addToCart()
        pageControl.layer.cornerRadius = 12
        print(viewModel?.product?.id ?? "")
        imgs = viewModel?.product?.images
        configureNib()
        configureScrollView()
        setupScrollView()
        setProductInfo()
        setupDropDownButton(sizeButton, options: viewModel?.product?.options?[0]?.values ?? [])
        setupDropDownButton(colorButton, options: viewModel?.product?.options?[1]?.values ?? [])
        viewModel?.isLoading
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel?.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                self?.loadingIndicator.isHidden = !isLoading
            })
            .disposed(by: disposeBag)
    }
    
    func setupDropDownButton(_ button: UIButton, options: [String]) {
        let menuClosure = { (action: UIAction) in
            self.update(number: action.title)
        }
        var children = [UIMenuElement]()
        for option in options {
            children.append(UIAction(title: option, state: .on, handler: menuClosure))
        }
        button.menu = UIMenu(children: children)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        //print(button.menu?.children.first?.title)
        
    }
    
    func update(number:String) {
        print("\(number) selected")
    }
    
    func getVariantTitle() -> String {
        sizeButton.currentTitle! + " / " + colorButton.currentTitle!
        //viewModel?.product
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
    
    private func addToCart() {
        viewModel?.addToCart.subscribe(onNext:  {isAdded in
            if isAdded {
                showToast(message: "Product added to shopping cart", vc: self)
            } else {
                showToast(message: "Product already exists in shopping cart", vc: self)
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func viewAll(_ sender: Any) {
        coordinator?.goToReviews(vc: self)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if checkInternetAndShowToast(vc: self){
            if AuthenticationManager.shared.isUserLoggedIn() {
                let variant = viewModel?.getSelectedVariant(title: getVariantTitle())
                viewModel?.fetchDraftOrder()
            }else{
                showAlertForNotUser(vc: self, coordinator: coordinator!)
            }
        }
    }
    
    @IBAction func addToWishList(_ sender: Any) {
        viewModel?.addToWishList(product: viewModel?.product, vc: self) { success in
            if success {
                showToast(message: "Product added to wishlist", vc: self)
            }
            else {
                showToast(message: "Product already exists in wishlist", vc: self)
            }
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        coordinator?.goBack()
    }
    
    func configureNib() {
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: .main)
        reviewsTableView.register(nib, forCellReuseIdentifier: "reviewCell")
    }
    
    func configureScrollView() {
        //        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height+680)
        reviewsTableView.frame.size.height = 420
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        pageControl.numberOfPages = imgs?.count ?? 0
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }
    
    func setupScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollViewWidth = scrollView.frame.size.width
        let scrollViewHeight = scrollView.frame.size.height
        
        for i in 0..<(imgs?.count ?? 0) {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.kf.setImage(with: URL(string: imgs?[i]?.src ?? ""))
            let xPosition = CGFloat(i) * scrollViewWidth
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(imgs?.count ?? 0), height: scrollViewHeight)
    }
    
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let scrollViewWidth = scrollView.frame.size.width
        let offset = CGPoint(x: CGFloat(currentPage) * scrollViewWidth, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    func setProductInfo(){
        productName.text = viewModel?.product?.title
        productPrice.text =  CurrencyService.calculatePriceAccordingToCurrency(price: String(viewModel?.product?.variants?.first??.price ?? "0"))
        descriptionTxt.text = viewModel?.product?.bodyHTML
    }
}

