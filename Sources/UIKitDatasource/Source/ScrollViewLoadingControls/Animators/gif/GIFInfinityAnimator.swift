//
//  GIFInfinityAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class GIFInfiniteAnimator: UIView, CustomInfiniteScrollAnimator {
    open var animatedImages = [UIImage]()

    var imageView = UIImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.imageView.frame = bounds
        addSubview(self.imageView)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func animateState(_ state: InfiniteScrollState) {
        switch state {
        case .loading:
            self.startAnimating()
        case .none:
            self.stopAnimating()
        }
    }

    func startAnimating() {
        self.imageView.animationImages = self.animatedImages
        self.imageView.isHidden = false
        self.imageView.startAnimating()
    }

    func stopAnimating() {
        self.imageView.isHidden = true
        self.imageView.stopAnimating()
    }
}
