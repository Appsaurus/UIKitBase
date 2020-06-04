//
//  BaseViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import DarkMagic
import Swiftest
import UIKitMixinable
import UIKitTheme

public protocol Reloadable {
    func reload(completion: @escaping () -> Void)
    var reloadFunction: ReloadFunction? { get set }
}

public typealias ReloadFunction = ((@escaping VoidClosure) -> Void)

private extension AssociatedObjectKeys {
    static let reloadFunction = AssociatedObjectKey<ReloadFunction?>("reloadFunction")
}

public extension Reloadable where Self: NSObject {
    var reloadFunction: ReloadFunction? {
        get {
            return self[.reloadFunction, nil]
        }
        set {
            self[.reloadFunction] = newValue
        }
    }
}

public extension Reloadable {
    func reload() {
        self.reload(completion: {})
    }
}

public protocol BaseViewControllerProtocol: BaseNSObjectProtocol
    & ViewControllerConfigurable
    & FirstResponderManaged
    & StatefulViewController
    & ViewRecycler
    & Reloadable
    & Styleable {}

extension BaseViewControllerProtocol where Self: UIViewController {
    public var baseViewControllerProtocolMixins: [LifeCycle] {
        return [ViewControllerConfigurableMixin(self),
                FirstResponderManagedMixin(self),
                StatefulViewControllerMixin(self),
                ViewRecyclerMixin(self),
                StyleableViewControllerMixin(self),
                ViewEdgesLayoutMixin(self),
                ManualScrollViewContentManagerMixin(self)]
            + baseNSObjectProtocolMixins
    }
}

open class BaseViewController: MixinableViewController, BaseViewControllerProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseViewControllerProtocolMixins
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
}
