//
//  AnimationViewController.swift
//  Shopify
//
//  Created by Aser Eid on 20/06/2024.
//

import UIKit

class AnimationViewController: UIViewController, Storyboarded {
    
    private let imageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "launch")
        return imageView
    }()
    
    private let defaults = UserDefaults.standard
    private let key = "isFirstTime"
    var coordinator : MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        
        if self.defaults.object(forKey: self.key) == nil {
            self.defaults.setValue(true, forKey: self.key )
        }
        let isFirstTime = self.defaults.bool(forKey: self.key )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        
            if isFirstTime == true {
                self.coordinator?.gotoOnBoard()
            }else{
                self.coordinator?.gotoTab()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.animate()
        })
    }
    
    private func animate(){
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(
                x: -(diffX / 2),
                y: diffY / 2,
                width: size,
                height: size
            )
        }
        
        UIView.animate(withDuration: 1.5) {
            self.imageView.alpha = 0
        }
    }
}
