//
//  StatefulViewControllerDefaultLoadingView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 6/30/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import UIKit

open class StatefulViewControllerDefaultLoadingView: StatefulViewControllerLoadingView {
    open var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    override open func startLoadingAnimation() {
        if !self.activityIndicator.isAnimating {
            self.activityIndicator.startAnimating()
        }
    }

    override open func stopLoadingAnimation() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.activityIndicator)
    }

    override open func createAutoLayoutConstraints() {
        self.activityIndicator.centerInSuperview()
    }
}

extension StatefulViewControllerView {
    static var defaultLoading: StatefulViewControllerDefaultLoadingView {
        return StatefulViewControllerDefaultLoadingView()
    }
}
