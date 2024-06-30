//
//  OnBoardingScreenViewController.swift
//  Storefy
//
//  Created by Aser Eid on 29/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class OnBoardingScreenViewController: UIViewController , Storyboarded {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var guestBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    var onBoardArr : [OnboardModel] = []
    var coordinator : MainCoordinator?
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        let nib = UINib(nibName: "OnBoardingCollectionViewCell", bundle: nil)
        myCollectionView.register(nib, forCellWithReuseIdentifier: "onBoardCell")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        onBoardArr = [
            OnboardModel(img: "onBoard1", title: "Explore Best Products", txtDetails: "Browse the brands and find your desire product. ") ,
            OnboardModel(img: "onboard2", title: "Easy and Secure Payment Method", txtDetails: "Pay for the product you buy safely and easily."),
            OnboardModel(img: "onboard3", title: "Quick and Free Local Delivery", txtDetails: "Your product is delivered in your place quickly and free among locals."),
            OnboardModel(img: "signin", title: "Storefy", txtDetails: "Shop Brands, Order Fast, Pay Your Way!")
        ]
        
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        let lastIndex = onBoardArr.count - 1
        scrollToIndex(index: lastIndex)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            scrollToIndex(index: currentIndex)
        }
        
    }
    
    @IBAction func getStartedBtn(_ sender: Any) {
        if currentIndex < onBoardArr.count - 2 {
            currentIndex += 1
            scrollToIndex(index: currentIndex)
        }
    }
    
    
    @IBAction func guestBtn(_ sender: Any) {
        coordinator?.gotoTab()
    }
    
    
    @IBAction func signInBtn(_ sender: Any) {
        coordinator?.goToLogin()
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if currentIndex < onBoardArr.count - 2 {
            currentIndex += 1
            scrollToIndex(index: currentIndex)
        }
    }
    
    func scrollToIndex(index : Int){
        let indexPath = IndexPath(item: index, section: 0)
        myCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentIndex = index
        updateButtonVisibility(for: indexPath)
    }
    
    func updateButtonVisibility(for indexPath: IndexPath) {
        backBtn.isHidden = indexPath.row == 0
        nextBtn.isHidden = indexPath.row >= onBoardArr.count - 1
        skipBtn.isHidden = indexPath.row >= onBoardArr.count - 1
        getStartedBtn.isHidden = indexPath.row != 2
        guestBtn.isHidden = indexPath.row != onBoardArr.count - 1
        signInBtn.isHidden = indexPath.row != onBoardArr.count - 1
    }
    
}

extension OnBoardingScreenViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onBoardArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onBoardCell", for: indexPath) as! OnBoardingCollectionViewCell
        
        cell.configureCell(onBoardItem: onBoardArr[indexPath.row])
        updateButtonVisibility(for: indexPath)
        //        if indexPath.row == 0 {
        //            backBtn.isHidden = true
        //            getStartedBtn.isHidden = true
        //            guestBtn.isHidden = true
        //            signInBtn.isHidden = true
        //        }else if indexPath.row == 1 {
        //            backBtn.isHidden = false
        //            getStartedBtn.isHidden = true
        //            guestBtn.isHidden = true
        //            signInBtn.isHidden = true
        //        }else if indexPath.row == 2 {
        //            backBtn.isHidden = false
        //            getStartedBtn.isHidden = false
        //            nextBtn.isHidden = true
        //            guestBtn.isHidden = true
        //            signInBtn.isHidden = true
        //        }else {
        //            guestBtn.isHidden = false
        //            signInBtn.isHidden = false
        //            nextBtn.isHidden = true
        //            getStartedBtn.isHidden = true
        //            backBtn.isHidden = true
        //            skipBtn.isHidden = true
        //            UserDefaults.standard.set(false, forKey: "isFirstTime")
        //        }
        //
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.myCollectionView.frame.width, height: self.myCollectionView.frame.height)
    }
    
}
