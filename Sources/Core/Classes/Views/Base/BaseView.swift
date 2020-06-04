//
//  BaseView.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable
import UIKitTheme

public protocol BaseNSObjectProtocol: DependencyInjectable
    & NotificationObserver {}

extension BaseNSObjectProtocol where Self: NSObject {
    public var baseNSObjectProtocolMixins: [LifeCycle] {
        return [DependencyInjectableViewMixin(self),
                NotificationObserverMixin(self)]
    }
}

public protocol BaseViewProtocol: BaseNSObjectProtocol
    & Roundable
    & Styleable {}

extension BaseViewProtocol where Self: UIView {
    public var baseViewProtocolMixins: [LifeCycle] {
        return [RoundableMixin(self),
                StyleableViewMixin(self)] + baseNSObjectProtocolMixins
    }
}

open class BaseView: MixinableView, BaseViewProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseViewProtocolMixins
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
