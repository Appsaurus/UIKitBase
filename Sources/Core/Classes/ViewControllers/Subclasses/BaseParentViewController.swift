//
//  BaseParentViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import Swiftest
import UIKit
import UIKitExtensions

open class BaseParentViewController: BaseContainerViewController {
    // If overridden to false, you must call loadChildViewController() explictly
    open func loadChildViewControllerImmediately() -> Bool {
        return true
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        if self.loadChildViewControllerImmediately() {
            self.loadChildViewController()
        }
    }

    open func loadChildViewController() {
        let child = self.initialChildViewController()
        if !children.contains(child) {
            add(child, to: containerView)
            child.loadViewIfNeeded()
        }
    }

    open func initialChildViewController() -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
            containerView.endEditing(true)
        }
    }
}
