//
//  BaseContainerViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/18/17.
//

import Foundation
import Layman
import UIKit

open class BaseContainerViewController: BaseViewController {
    open lazy var headerView: UIView? = {
        self.createHeaderView()
    }()

    /// Hook to create a static header view that is pinned above the containerview.
    ///
    /// - Returns: Header view, height determined by subview autolayout constraints
    open func createHeaderView() -> UIView? {
        return nil
    }

    open lazy var containerView: UIView = UIView()
    open lazy var containedView: UIView? = nil

    override open func createSubviews() {
        super.createSubviews()
        view.addSubview(self.containerView)
        if let containedView = containedView {
            self.containerView.addSubview(containedView)
        }

        guard let headerView = headerView else { return }
        view.addSubview(headerView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.createContainedViewLayoutConstraints()
        self.createContainerViewLayoutConstraints()
    }

    open func createContainerViewLayoutConstraints() {
        view.removeLayoutMarginsInset(removingSafeAreaInset: true)
        self.containerView.removeLayoutMarginsInset(removingSafeAreaInset: true)
        view.layoutMargins = .zero
        self.containerView.layoutMargins = .zero
        if #available(iOS 11.0, *) {
            view.directionalLayoutMargins = .zero
            viewRespectsSystemMinimumLayoutMargins = false
        }
        guard let headerView = headerView else {
            self.containerView.pinToSuperviewMargins()
            return
        }
        [headerView, self.containerView].stack(.topToBottom, in: view.margins)
        headerView.enforceContentSize()
    }

    open func createContainedViewLayoutConstraints() {
        if let containedView = containedView {
            containedView.equal(to: self.containerView.margins.edges)
        }
        self.containerView.layoutMargins = .zero
    }
}
