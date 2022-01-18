//
//  BaseUILabel.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKitMixinable

public protocol BaseUILabelProtocol: BaseViewProtocol {}

public extension BaseUILabelProtocol where Self: UILabel {
    var baseUILabelProtocolMixins: [LifeCycle] {
        return baseViewProtocolMixins
    }
}

open class BaseUILabel: MixinableLabel, BaseUILabelProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseUILabelProtocolMixins
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
