//
//  BaseTabBarController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import Foundation
import Swiftest
import UIKitMixinable

public protocol BaseTabBarControllerProtocol: BaseViewControllerProtocol {}

extension BaseTabBarControllerProtocol where Self: UITabBarController {
    public var baseTabBarControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseTabBarController: MixinableTabBarController, BaseTabBarControllerProtocol, UITabBarControllerDelegate {
    open var initialSelectedIndex: Int? = 0

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTabBarControllerProtocolMixins
    }

    open override func setupDelegates() {
        super.setupDelegates()
        delegate = self
    }

    // MARK: LifeCycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex =? initialSelectedIndex
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

    // MARK: UITabBarControllerDelegate

    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let childVC = viewController as? TabBarChild else {
            return
        }

        childVC.tabBarChildDidAppear()
    }

    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let vc = selectedViewController else { return }
        if vc.tabBarItem == item, vc.isViewLoaded == true {
            self.tabBar(tabBar, didReselect: vc)
        }
    }

    open func tabBar(_ tabBar: UITabBar, didReselect viewController: UIViewController) {
        guard let childVC = self.selectedViewController as? TabBarChild else {
            return
        }
        childVC.tabItemWasTappedWhileActive()
    }

    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let placeholderVC = viewController as? TabBarControllerModalChildPlaceholder else { return true }
        let modalVC = modalViewControllerToPresent(inPlaceOf: placeholderVC)
        self.tabBarController(self, willPresentModal: modalVC)
        present(viewController: modalVC)
        return false
    }

    open func modalViewControllerToPresent(inPlaceOf placeholderViewController: TabBarControllerModalChildPlaceholder) -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }

    open func tabBarController(_ tabBarController: UITabBarController, willPresentModal viewController: UIViewController) {}
}

open class TabBarControllerModalChildPlaceholder: UIViewController {}
