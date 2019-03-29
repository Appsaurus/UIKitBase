//
//  GIFRefreshAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class GIFRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    
    open var refreshImages = [UIImage]()
    open var animatedImages = [UIImage]()
    
    fileprivate var imageView:UIImageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = self.bounds
        
        self.addSubview(imageView)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            stopAnimating()
        case .releasing(let progress):
            updateForProgress(progress)
        case .loading:
            startAnimating()
        }
    }
    func updateForProgress(_ progress: CGFloat) {
        if refreshImages.count > 0 {
            let currentIndex = min(Int(progress * CGFloat(refreshImages.count)), refreshImages.count - 1)
            imageView.image = refreshImages[currentIndex]
        }
    }
    func startAnimating() {
        imageView.animationImages = animatedImages
        imageView.startAnimating()
    }
    func stopAnimating() {
        imageView.stopAnimating()
        imageView.image = refreshImages.first
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
