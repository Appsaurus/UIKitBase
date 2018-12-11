//
//  BaseViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import UIKitMixinable
import UIKitTheme
import DinoDNA

public protocol BaseViewControllerProtocol:
    BaseNSObjectProtocol
    & ViewControllerConfigurable
    & FirstResponderManaged
    & NavigationBarStyleable
    & StatefulViewController
    & Styleable
{}

extension BaseViewControllerProtocol where Self: UIViewController{
    public var baseViewControllerProtocolMixins: [LifeCycle]{
        return [ViewControllerConfigurableMixin(self),
                FirstResponderManagedMixin(self),
                NavigationBarStyleableMixin(self),
                StatefulViewControllerMixin(self),
                StyleableViewControllerMixin(self)]
            + baseNSObjectProtocolMixins
    }
}

open class BaseViewController: MixinableViewController, BaseViewControllerProtocol {
    
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseViewControllerProtocolMixins
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
    
    open func didObserve(notification: Notification){
        
    }
    
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
    

}
