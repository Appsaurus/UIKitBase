//
//  BaseScrollingViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Layman
import UIKit
import UIKitTheme

open class BaseScrollingViewController: BaseViewController {
    public let scrollView = UIScrollView().then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }

    public let scrollViewContentView = UIView()
    public lazy var contentView: UIView = createContentView()

    // Override this view or add all subviews to this view with proper autolayout constraints
    open func createContentView() -> UIView {
        return UIView()
    }

    override public func initProperties() {
        super.initProperties()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    override open func createSubviews() {
        super.createSubviews()
        view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.scrollViewContentView)
        self.scrollViewContentView.addSubview(self.contentView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.scrollView.pinToSuperview()

        self.scrollViewContentView.centerX.equalToSuperview()
        self.scrollViewContentView.centerY.equal(to: self.scrollView.centerY.priority(.low))
        self.scrollViewContentView.pinToSuperview(excluding: .bottom)
        self.scrollViewContentView.bottom.equal(to: self.scrollView.bottom.priority(.low))
        self.contentView.forceSuperviewToMatchContentSize()
    }
}
