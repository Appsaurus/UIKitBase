//
//  StatefulViewControllerDefaultLoadingView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 6/30/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import UIKit

open class StatefulViewControllerDefaultLoadingView: StatefulViewControllerLoadingView {
    open var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    open override func initialArrangedSubviews() -> [UIView] {
        return [activityIndicator]
    }

    open override func startLoadingAnimation() {
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
    }

    open override func stopLoadingAnimation() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
    }
}
