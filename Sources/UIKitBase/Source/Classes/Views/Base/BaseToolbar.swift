//
//  BaseToolbar.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseToolbarProtocol: BaseViewProtocol {}

public extension BaseToolbarProtocol where Self: UIToolbar {
    var baseToolbarProtocolMixins: [LifeCycle] {
        return [] + baseViewProtocolMixins
    }
}

open class BaseToolbar: MixinableToolbar, BaseToolbarProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseToolbarProtocolMixins
    }

    // MARK: UIViewLifeCycle Overrides

    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        bindStyle()
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
