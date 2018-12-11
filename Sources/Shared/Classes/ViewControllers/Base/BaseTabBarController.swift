//
//  BaseTabBarController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 12/3/18.
//

import Foundation
import DinoDNA
import UIKitMixinable

public protocol BaseTabBarControllerProtocol:
    BaseViewControllerProtocol
{}

extension BaseTabBarControllerProtocol where Self: UITabBarController{
    public var baseTabBarControllerProtocolMixins: [LifeCycle]{
        return baseViewControllerProtocolMixins
    }
}

open class BaseTabBarController: MixinableTabBarController, BaseTabBarControllerProtocol, UITabBarControllerDelegate{
    
    open var initialSelectedIndex: Int? = 0
    
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTabBarControllerProtocolMixins
    }
    
    open override func setupDelegates() {
        super.setupDelegates()
        delegate = self
    }

    //MARK: LifeCycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex =? initialSelectedIndex
    }
    
    //MARK: Orientation
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return currentSupportedInterfaceOrientation
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return statusBarAnimation
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle
    }
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    //MARK: NotificationObserver
    open func notificationsToObserve() -> [Notification.Name]{
        return []
    }
    open func notificationClosureMap() -> NotificationClosureMap{
        return [:]
    }
    
    open func didObserve(notification: Notification){}
    
    //MARK: Styleable
    open func style() {
        applyBaseViewStyle()
    }
    
    //MARK: StatefulViewController
    open func startLoading(){}
    
    open func customizeStatefulViews() {}
    
    open func createStatefulViews() -> StatefulViewMap {
        return [:]
    }
    
    open func willTransition(to state: State){}
    
    open func didTransition(to state: State){}

    //MARK: UITabBarControllerDelegate    
    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        guard let childVC = viewController as? TabBarChildViewControllerProtocol else {
            return
        }
        
        childVC.tabBarChildViewControllerDidAppear()
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let vc = selectedViewController else { return }
        if vc.tabBarItem == item && vc.isViewLoaded == true{
            self.tabBar(tabBar, didReselect: vc)
        }
    }
    
    open func tabBar(_ tabBar: UITabBar, didReselect viewController: UIViewController){
        guard let childVC = self.selectedViewController as? TabBarChildViewControllerProtocol else {
            return
        }
        childVC.tabItemWasTappedWhileViewControllerIsVisible()
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let placeholderVC = viewController as? TabBarControllerModalChildPlaceholder else { return true }
        let modalVC = modalViewControllerToPresent(inPlaceOf: placeholderVC)
        self.tabBarController(self, willPresentModal: modalVC)
        self.present(viewController: modalVC)
        return false
    }
    
    open func modalViewControllerToPresent(inPlaceOf placeholderViewController: TabBarControllerModalChildPlaceholder) -> UIViewController{
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, willPresentModal viewController: UIViewController) {}
}

open class TabBarControllerModalChildPlaceholder: UIViewController{}
