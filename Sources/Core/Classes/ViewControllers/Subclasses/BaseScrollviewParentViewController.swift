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

    override open func createSubviews() {
        super.createSubviews()
        scrollViewContentView.addSubview(self.childViewControllerContainerView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.childViewControllerContainerView.pinToSuperview()
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        add(self.initialChildViewController(), to: self.childViewControllerContainerView)
    }

    open func initialChildViewController() -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }
}
