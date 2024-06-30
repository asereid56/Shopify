//
//  WishListViewController.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import UIKit
import RxCocoa
import RxSwift

class WishlistViewController: UIViewController , Storyboarded{
    
    @IBOutlet weak var noInternetImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var wishlistCollectionView: UICollectionView!
    
    var coordinator: MainCoordinator?
    var viewModel: WishListViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkonUserDefaultsValues()
        checkUser()
        configureNib()
        wishlistCollectionView.collectionViewLayout = createLayout()
        selectItemToNavigate()
        if checkInternetAndShowToast(vc: self) {
            setUpBinding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if checkInternetAndShowToast(vc: self) {
            viewModel?.fetchData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        coordinator?.goBack()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        coordinator?.goToLogin()
    }
    @IBAction func signupTapped(_ sender: Any) {
        coordinator?.goToSignUp()
    }
}

extension WishlistViewController {
    
    func configureNib() {
        let nib = UINib(nibName: "WishCollectionViewCell", bundle: nil)
        wishlistCollectionView.register(nib, forCellWithReuseIdentifier: "wishCell")
    }
    
    func setup() {
        let itemWidth = (wishlistCollectionView.frame.width / 2 ) - 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        wishlistCollectionView.collectionViewLayout = layout
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setUpBinding() {
        viewModel?.items
            .bind(to: wishlistCollectionView.rx.items(cellIdentifier: "wishCell", cellType: WishCollectionViewCell.self)) { [weak self] index, item, cell in
                cell.configure(with: item)
                cell.removeButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.showDeleteConfirmationAlert(for: index)
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            }
            .disposed(by: disposeBag)
        
        viewModel?.isEmpty
            .map { !$0 }
            .bind(to: emptyImg.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel?.isEmpty
            .map { !$0 }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel?.isLoading
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel!.isLoading, viewModel!.isEmpty)
            .subscribe(onNext: { [weak self] isLoading, isEmpty in
                self?.loadingIndicator.isHidden = !isLoading
                self?.emptyImg.isHidden = isLoading || !isEmpty
                self?.emptyLabel.isHidden = isLoading || !isEmpty
                self?.wishlistCollectionView.isHidden = isLoading
            })
            .disposed(by: disposeBag)
    }
    
    func showDeleteConfirmationAlert(for index: Int) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel?.requestDeleteItem(at: index)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func selectItemToNavigate(){
        if checkInternetAndShowToast(vc: self) {
            wishlistCollectionView.rx.modelSelected(LineItem.self)
                .subscribe(onNext: { [weak self] product in
                    guard let self = self else { return }
                    let arr = product.sku?.components(separatedBy: " ")
                    self.coordinator?.goToProductInfo(productId: String(arr?[1] ?? ""))
                    
                })
                .disposed(by: disposeBag)
        }
    }
    
    func checkUser() {
        if !checkInternetAndShowToast(vc: self) {
            noInternetImage.isHidden = false
        }
        else {
            noInternetImage.isHidden = true
        }
    }
}