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

    var imageView: UIImageView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.frame = bounds
        addSubview(imageView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func animateState(_ state: InfiniteScrollState) {
        switch state {
        case .loading:
            startAnimating()
        case .none:
            stopAnimating()
        }
    }

    func startAnimating() {
        imageView.animationImages = animatedImages
        imageView.isHidden = false
        imageView.startAnimating()
    }

    func stopAnimating() {
        imageView.isHidden = true
        imageView.stopAnimating()
    }
}
