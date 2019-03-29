//
//  BaseTableViewHeaderFooterView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseTableViewHeaderFooterViewProtocol: BaseViewProtocol {}

extension BaseTableViewHeaderFooterViewProtocol where Self: UITableViewHeaderFooterView {
    public var baseTableViewHeaderFooterViewProtocolMixins: [LifeCycle] {
        return baseViewProtocolMixins
    }
}

open class BaseUITableViewHeaderFooterView: MixinableTableViewHeaderFooterView, BaseTableViewHeaderFooterViewProtocol {
    
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewHeaderFooterViewProtocolMixins
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
    open func style() {}

}
