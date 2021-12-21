//
//  BaseNavigationController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable
import UIKitTheme

public protocol BaseNavigationControllerProtocol: BaseViewControllerProtocol {}

public extension BaseNavigationControllerProtocol where Self: UINavigationController {
    var baseNavigationControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseNavigationController: MixinableNavigationController, BaseNavigationControllerProtocol {
    public var overridesChildStatusBarStyles: Bool = false

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseNavigationControllerProtocolMixins
    }

    // MARK: Orientation

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentSupportedInterfaceOrientation
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        guard overridesChildStatusBarStyles else {
            return (topViewController as? BaseViewController)?.statusBarAnimation ?? statusBarAnimation
        }
        return statusBarAnimation
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        guard overridesChildStatusBarStyles else {
            return (topViewController as? BaseViewController)?.statusBarStyle ?? statusBarStyle
        }
        return statusBarStyle
    }

    override open var prefersStatusBarHidden: Bool {
        guard overridesChildStatusBarStyles else {
            return (topViewController as? BaseViewController)?.statusBarHidden ?? statusBarHidden
        }
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
        view.backgroundColor = currentStyle.navigationControllerBaseViewBackgroundColor
    }

    // MARK: Reloadable

    open func reload(completion: @escaping () -> Void) {
        reloadFunction?(completion)
    }

    // MARK: StatefulViewController

    open func customizeStatefulViews() {}

    open func createStatefulViews() -> StatefulViewMap {
        return [:]
    }

    open func willTransition(to state: State) {}

    open func didTransition(to state: State) {}

    open func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel {
        return .error(error, retry: loadAsyncData)
    }

    // MARK: ViewRecycler

    open func registerReusables() {}
}
