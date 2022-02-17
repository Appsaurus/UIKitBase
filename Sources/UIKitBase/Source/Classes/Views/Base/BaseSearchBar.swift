//
//  BaseSearchBar.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable

public protocol BaseSearchBarProtocol: BaseViewProtocol {}

public extension BaseSearchBarProtocol where Self: UISearchBar {
    var baseSearchBarProtocolMixins: [LifeCycle] {
        return baseViewProtocolMixins
    }
}

open class BaseSearchBar: MixinableSearchBar, BaseSearchBarProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseSearchBarProtocolMixins
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
