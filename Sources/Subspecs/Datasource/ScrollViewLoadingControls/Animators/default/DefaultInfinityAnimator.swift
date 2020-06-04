//
//  DefaultInfinityAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class DefaultInfiniteAnimator: UIView, CustomInfiniteScrollAnimator {
    open var activityIndicatorView: UIActivityIndicatorView
    open fileprivate(set) var animating: Bool = false

    override public init(frame: CGRect) {
        self.activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.isHidden = true

        super.init(frame: frame)

        addSubview(self.activityIndicatorView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.activityIndicatorView.frame = bounds
    }

    override open func didMoveToWindow() {
        if window != nil, self.animating {
            self.startAnimating()
        }
    }

    open func animateState(_ state: InfiniteScrollState) {
        print(state)
        switch state {
        case .none:
            self.stopAnimating()
        case .loading:
            self.startAnimating()
        }
    }

    func startAnimating() {
        self.animating = true

        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
    }

    func stopAnimating() {
        self.animating = false

        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
