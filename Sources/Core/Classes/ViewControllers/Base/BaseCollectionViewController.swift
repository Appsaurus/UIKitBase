//
//  BaseCollectionViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseCollectionViewControllerProtocol: BaseViewControllerProtocol {}

extension BaseCollectionViewControllerProtocol where Self: UICollectionViewController {
    public var baseCollectionViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseCollectionViewController: MixinableCollectionViewController, BaseCollectionViewControllerProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseCollectionViewControllerProtocolMixins
    }

    // MARK: Orientation

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentSupportedInterfaceOrientation
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override open var prefersStatusBarHidden: Bool {
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

    // MARK: Reloadable

    open func reload(completion: @escaping () -> Void) {
        reloadFunction?(completion)
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return .default(for: self)
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}

    open func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel {
        return .error(error, retry: loadAsyncData)
    }

    // MARK: ViewRecycler

    open func registerReusables() {}
}
