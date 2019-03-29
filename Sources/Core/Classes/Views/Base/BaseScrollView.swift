//
//  BaseScrollView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseScrollViewProtocol:
    BaseViewProtocol
{}

extension BaseScrollViewProtocol where Self: UIScrollView{
    public var baseScrollViewProtocolMixins: [LifeCycle]{
        return [] + baseViewProtocolMixins
    }
}

open class BaseScrollView: MixinableScrollView, BaseScrollViewProtocol{
    
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseScrollViewProtocolMixins
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
    open func style() {}
    

}

