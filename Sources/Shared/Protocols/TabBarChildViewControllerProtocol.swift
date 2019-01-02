//
//  TabBarChildViewControllerProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 1/15/17.
//
//

import Foundation
import UIKit
import Swiftest

public protocol TabBarChildViewControllerProtocol {
    //Must be called by TabBarController at proper times
    func tabBarChildViewControllerDidAppear()
    func tabItemWasTappedWhileViewControllerIsVisible()
}

//Forwards protocol calls to vc at end of navigation stack by default
extension TabBarChildViewControllerProtocol {
    
    public func tabBarChildViewControllerDidAppear(){
        guard let navVC = self as? UINavigationController else{
            return
        }
        guard let topOfStackVC = navVC.viewControllers.last as? TabBarChildViewControllerRefreshable else{
            return
        }
        topOfStackVC.tabBarChildViewControllerDidAppear()
    }
    public func tabItemWasTappedWhileViewControllerIsVisible(){
        guard let navVC = self as? UINavigationController else{
            return
        }
        guard let topOfStackVC = navVC.viewControllers.last as? TabBarChildViewControllerRefreshable else{
            return
        }
        topOfStackVC.tabItemWasTappedWhileViewControllerIsVisible()
    }
    
    public func defaultTabBarTappedWhileActiveAction(viewController: TabBarChildViewControllerRefreshable){
        TabRefreshStepper.performNextRefreshStep(refreshable: viewController)
    }
}

extension TabBarChildViewControllerProtocol where Self: BaseNavigationController {
    public func refresh(){
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }
    public func scrollViewToRefresh() -> UIScrollView? {
        return nil
    }
}

public protocol TabBarChildViewControllerRefreshable: TabBarChildViewControllerProtocol{
    func refresh()
    func scrollViewToRefresh() -> UIScrollView?
}

class TabRefreshStepper{
    class func performNextRefreshStep(refreshable: TabBarChildViewControllerRefreshable){
        guard let scrollView = refreshable.scrollViewToRefresh() else{
            debugLog("No scrollView to refresh set")
            refreshable.refresh()
            return
        }
        
        if scrollView.yOffsetPosition == .top{
            refreshable.refresh()
        }
        else{
            scrollView.scrollToTop()
        }
    }
    
}

//Forwards protocol calls to vc at end of navigation stack by default
public extension TabBarChildViewControllerRefreshable{
    public func tabItemWasTappedWhileViewControllerIsVisible(){
        guard let navVC = self as? UINavigationController else{
            defaultTabBarTappedWhileActiveAction(viewController: self)
            return
        }
        guard let topOfStackVC = navVC.viewControllers.last as? TabBarChildViewControllerRefreshable else{
            return
        }
        defaultTabBarTappedWhileActiveAction(viewController: topOfStackVC)
    }
    
    public func defaultTabBarTappedWhileActiveAction(viewController: TabBarChildViewControllerRefreshable){
        TabRefreshStepper.performNextRefreshStep(refreshable: viewController)
    }
    
    public func refresh(){
        
        guard let navVC = self as? UINavigationController else{
            assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
            return
        }
        guard let topOfStackVC = navVC.viewControllers.last as? TabBarChildViewControllerRefreshable else{
            return
        }
        topOfStackVC.refresh()
    }
    
    public func scrollViewToRefresh() -> UIScrollView? {
        return nil
    }
}
extension TabBarChildViewControllerRefreshable where Self: BaseCollectionViewController{
    public func scrollViewToRefresh() -> UIScrollView? {
        return collectionView
    }
}
extension TabBarChildViewControllerRefreshable where Self: BaseTableViewController {
    public func scrollViewToRefresh() -> UIScrollView? {
        return tableView
    }
}

extension TabBarChildViewControllerRefreshable where Self: BaseViewController {
    public func scrollViewToRefresh() -> UIScrollView? {
        return nil
    }
}


extension TabBarChildViewControllerRefreshable where Self: BaseNavigationController {
    public func refresh(){
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }
    public func scrollViewToRefresh() -> UIScrollView? {
        return nil
    }
}
