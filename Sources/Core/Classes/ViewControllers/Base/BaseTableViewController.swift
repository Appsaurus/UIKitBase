//
//  BaseTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKit
import Swiftest
import UIKitMixinable

public protocol BaseTableViewControllerProtocol: BaseViewControllerProtocol
    & ViewRecycler {}

extension BaseTableViewControllerProtocol where Self: UITableViewController {
    public var baseTableViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins + [ViewRecyclerMixin(self)]
    }
}

open class BaseTableViewController: MixinableTableViewController, BaseTableViewControllerProtocol {
    
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewControllerProtocolMixins
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
        self.tableView.apply(tableViewStyle: .defaultStyle)
    }
    
    // MARK: StatefulViewController
    open func startLoading() {}
    
    open func customizeStatefulViews() {}
    
    open func createStatefulViews() -> StatefulViewMap {
        return [:]
    }
    
    open func willTransition(to state: State) {}
    
    open func didTransition(to state: State) {}

}
