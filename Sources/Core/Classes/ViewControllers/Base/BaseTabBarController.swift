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

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTabBarControllerProtocolMixins
    }

    override open func setupDelegates() {
        super.setupDelegates()
        delegate = self
    }

    // MARK: LifeCycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex =? self.initialSelectedIndex
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

    override open func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let vc = selectedViewController else { return }
        if vc.tabBarItem == item, vc.isViewLoaded == true {
            self.tabBar(tabBar, didReselect: vc)
        }
    }

    open func tabBar(_ tabBar: UITabBar, didReselect viewController: UIViewController) {
        guard let childVC = selectedViewController as? TabBarChild else {
            return
        }
        childVC.tabItemWasTappedWhileActive()
    }

    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let placeholderVC = viewController as? TabBarControllerModalChildPlaceholder else { return true }
        let modalVC = self.modalViewControllerToPresent(inPlaceOf: placeholderVC)
        self.tabBarController(self, willPresentModal: modalVC)
        present(viewController: modalVC)
        return false
    }

    open func modalViewControllerToPresent(inPlaceOf placeholderViewController: TabBarControllerModalChildPlaceholder) -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }

    open func tabBarController(_ tabBarController: UITabBarController, willPresentModal viewController: UIViewController) {}

    //MARK: ViewRecycler

    open func registerReusables() {}

}

open class TabBarControllerModalChildPlaceholder: UIViewController {}
