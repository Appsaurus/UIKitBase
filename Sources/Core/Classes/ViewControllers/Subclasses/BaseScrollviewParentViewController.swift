//
//  BaseScrollviewParentViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Layman
import UIKitMixinable
open class BaseScrollviewParentViewController: BaseScrollviewController, UIGestureRecognizerDelegate {
    open var childViewControllerContainerView: UIView = UIView()

    open override func createSubviews() {
        super.createSubviews()
        scrollViewContentView.addSubview(childViewControllerContainerView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        childViewControllerContainerView.pinToSuperview()
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        add(initialChildViewController(), to: childViewControllerContainerView)
    }

    open func initialChildViewController() -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }
}
