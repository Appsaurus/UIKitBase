//
//  BasePageViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

public protocol BasePageViewControllerProtocol: BaseViewControllerProtocol {}

extension BasePageViewControllerProtocol where Self: UIPageViewController {
    public var basePageViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BasePageViewController: MixinablePageViewController, BasePageViewControllerProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + basePageViewControllerProtocolMixins
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
        view.backgroundColor = currentStyle.pagingViewControllerBaseViewBackgroundColor
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return [:]
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}
}
