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
    open var containerScrollView = ContainerScrollView(contentView: UIView())

    override open func setupDelegates() {
        super.setupDelegates()
        self.scrollView.delegate = self
    }

    open var scrollViewContentView: UIView {
        return self.containerScrollView.contentView
    }

    fileprivate var additionalPaddingForScrollViewHeaderContent: CGFloat = 0.0
    fileprivate var expandContentSizeHeight: CGFloat = 0.0

    override open func createSubviews() {
        super.createAutoLayoutConstraints()
        view.addSubview(self.scrollView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.scrollView.pinToSuperview()
        self.scrollView.bringSubviewToFront(self.scrollViewContentView)
//        scrollView.top.greaterThanOrEqual(to: 0)
    }

//    open override func didFinishCreatingAllViews() {
//        super.didFinishCreatingAllViews()
//        containerScrollView.childScrollViews.forEach { $0.contentInset = self.scrollView.contentInset}
//    }
}
