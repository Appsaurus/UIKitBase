//
//  BaseViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import Swiftest
import UIKitMixinable
import UIKitTheme

public protocol BaseViewControllerProtocol: BaseNSObjectProtocol
    & ViewControllerConfigurable
    & FirstResponderManaged
    & StatefulViewController
    & Styleable {}

extension BaseViewControllerProtocol where Self: UIViewController {
    public var baseViewControllerProtocolMixins: [LifeCycle] {
        return [ViewControllerConfigurableMixin(self),
                FirstResponderManagedMixin(self),
                StatefulViewControllerMixin(self),
                StyleableViewControllerMixin(self)]
            + baseNSObjectProtocolMixins
    }
}

open class BaseViewController: MixinableViewController, BaseViewControllerProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseViewControllerProtocolMixins
    }

    // MARK: Orientation

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentSupportedInterfaceOrientation
    }

    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    open override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    // MARK: NotificationObserver

    open func notificationsToObserve() -> [Notification.Name] {
        return []
    }

    open func notificationClosureMap() -> NotificationClosureMap {
        return [:]
    }

    open func didObserve(notification: Notification) {}

    // MARK: Styleable

    open func style() {
        applyBaseViewStyle()
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return .default
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}
}
