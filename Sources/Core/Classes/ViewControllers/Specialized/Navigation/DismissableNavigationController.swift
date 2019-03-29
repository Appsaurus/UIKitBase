//
//  DismissableNavigationController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/24/18.
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

open class DismissableNavigationController: BaseNavigationController, DismissButtonManaged, UINavigationControllerDelegate {
    private var dismissButtonConfiguration: ManagedButtonConfiguration = ManagedButtonConfiguration()
    private var dismissableViewController: (UIViewController & DismissButtonManaged)!
    public required init<VC: UIViewController & DismissButtonManaged>(dismissableViewController: VC,
                                                                      dismissButtonConfiguration: ManagedButtonConfiguration = ManagedButtonConfiguration()) {
        super.init(rootViewController: dismissableViewController)
        self.dismissButtonConfiguration = dismissButtonConfiguration
        self.dismissableViewController = dismissableViewController
        self.dismissableViewController.setupDismissButton(configuration: self.dismissButtonConfiguration)
        delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self.viewControllers.first, let dismissableViewController = viewController as? UIViewController & DismissButtonManaged {
            dismissableViewController.setupDismissButton(configuration: self.dismissButtonConfiguration)
        }
    }
    
}
