//
//  DismissableNavigationController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/24/18.
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

open class DismissableNavigationController: BaseNavigationController, UINavigationControllerDelegate {
    private var dismissableViewController: (UIViewController & DismissButtonManaged)!
    public required init<VC: UIViewController & DismissButtonManaged>(dismissableViewController: VC) {
        super.init(rootViewController: dismissableViewController)
        self.dismissableViewController = dismissableViewController
        self.dismissableViewController.setupDismissButton()
        delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === viewControllers.first,
            var dismissableViewController = viewController as? DismissButtonManaged {
            dismissableViewController.setupDismissButton()
        }
    }
}
