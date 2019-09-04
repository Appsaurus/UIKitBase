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

    open var scrollViewContentView: UIView {
        return containerScrollView.contentView
    }


    fileprivate var additionalPaddingForScrollViewHeaderContent: CGFloat = 0.0
    fileprivate var expandContentSizeHeight: CGFloat = 0.0

    open override func createSubviews() {
        super.createAutoLayoutConstraints()
        view.addSubview(scrollView)
    }

    open override func setupDelegates() {
        super.setupDelegates()
        let singleTap = UITapGestureRecognizer()
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)


        let otherTap = UITapGestureRecognizer()
        otherTap.cancelsTouchesInView = false
        otherTap.numberOfTapsRequired = 1
        containerScrollView.addGestureRecognizer(otherTap)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        scrollView.pinToSuperview()
        scrollView.bringSubviewToFront(scrollViewContentView)
    }
}
