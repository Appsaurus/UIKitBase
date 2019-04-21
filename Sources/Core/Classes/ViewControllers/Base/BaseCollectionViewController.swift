//
//  BaseCollectionViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseCollectionViewControllerProtocol: BaseViewControllerProtocol
    & ViewRecycler {}

extension BaseCollectionViewControllerProtocol where Self: UICollectionViewController {
    public var baseCollectionViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins + [ViewRecyclerMixin(self)]
    }
}

open class BaseCollectionViewController: MixinableCollectionViewController, BaseCollectionViewControllerProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseCollectionViewControllerProtocolMixins
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
        collectionView?.apply(collectionViewStyle: .defaultStyle)
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return .default
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}
}
