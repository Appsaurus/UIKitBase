//
//  BaseContainerViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/18/17.
//

import Foundation
import UIKit
import Layman

open class BaseContainerViewController: BaseViewController {

    open lazy var headerView: UIView? = {
        return self.createHeaderView()
    }()


    /// Hook to create a static header view that is pinned above the containerview.
    ///
    /// - Returns: Header view, height determined by subview autolayout constraints
    open func createHeaderView() -> UIView?{
        return nil
    }

    open lazy var containerView: UIView = UIView()
    open lazy var containedView: UIView? = nil

    open override func createSubviews(){
        super.createSubviews()
        view.addSubview(containerView)
        if let containedView = containedView {
            containerView.addSubview(containedView)
        }

        guard let headerView = headerView else { return }
        view.addSubview(headerView)
    }

    open override func createAutoLayoutConstraints(){
        super.createAutoLayoutConstraints()
        createContainedViewLayoutConstraints()
        createContainerViewLayoutConstraints()
    }

    open func createContainerViewLayoutConstraints(){
        view.layoutMargins = .zero
        if #available(iOS 11.0, *) {
            view.directionalLayoutMargins = .zero
            viewRespectsSystemMinimumLayoutMargins = false
        }
        guard let headerView = headerView else {
            containerView.pinToSuperviewMargins()
            return
        }
        [headerView, containerView].stack(.topToBottom, in: view.margins)
        headerView.enforceContentSize()
    }

    open func createContainedViewLayoutConstraints(){
        if let containedView = containedView {
            containedView.equal(to: containerView.margins.edges)
        }
        containerView.layoutMargins = .zero
    }
}

