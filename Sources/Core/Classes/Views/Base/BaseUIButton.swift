//
//  BaseButton.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseButtonProtocol: BaseViewProtocol {}

extension BaseButtonProtocol where Self: UIButton {
    public var baseButtonProtocolMixins: [LifeCycle] {
        return baseViewProtocolMixins
    }
}

open class BaseUIButton: MixinableButton, BaseButtonProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseButtonProtocolMixins
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
