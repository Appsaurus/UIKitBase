//
//  BaseScrollviewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import UIKit

open class BaseScrollviewController: BaseViewController, UIScrollViewDelegate {
    open lazy var scrollView: UIScrollView = containerScrollView
    open var containerScrollView: ContainerScrollView = ContainerScrollView(contentView: UIView())

    open override func setupDelegates() {
        super.setupDelegates()
        scrollView.delegate = self
    }

    open var scrollViewContentView: UIView {
        return containerScrollView.contentView
    }

    fileprivate var additionalPaddingForScrollViewHeaderContent: CGFloat = 0.0
    fileprivate var expandContentSizeHeight: CGFloat = 0.0

    open override func createSubviews() {
        super.createAutoLayoutConstraints()
        view.addSubview(scrollView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        scrollView.pinToSuperview()
        scrollView.bringSubviewToFront(scrollViewContentView)
//        scrollView.top.greaterThanOrEqual(to: 0)
    }
//    open override func didFinishCreatingAllViews() {
//        super.didFinishCreatingAllViews()
//        containerScrollView.childScrollViews.forEach { $0.contentInset = self.scrollView.contentInset}
//    }
}
