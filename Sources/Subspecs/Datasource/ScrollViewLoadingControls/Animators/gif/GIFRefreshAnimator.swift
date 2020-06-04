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

    fileprivate var imageView: UIImageView = UIImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.imageView.frame = bounds

        addSubview(self.imageView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            self.stopAnimating()
        case let .releasing(progress):
            self.updateForProgress(progress)
        case .loading:
            self.startAnimating()
        }
    }

    func updateForProgress(_ progress: CGFloat) {
        if self.refreshImages.count > 0 {
            let currentIndex = min(Int(progress * CGFloat(self.refreshImages.count)), self.refreshImages.count - 1)
            self.imageView.image = self.refreshImages[currentIndex]
        }
    }

    func startAnimating() {
        self.imageView.animationImages = self.animatedImages
        self.imageView.startAnimating()
    }

    func stopAnimating() {
        self.imageView.stopAnimating()
        self.imageView.image = self.refreshImages.first
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
