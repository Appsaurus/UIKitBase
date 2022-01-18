//
//  NotificationObserver.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import Actions
import UIKitExtensions
import UIKitMixinable
public typealias NotificationClosure = (Notification) -> Void
public typealias NotificationClosureMap = [Notification.Name: NotificationClosure]

public protocol NotificationObserver: AnyObject {
    func setupNotificationObserverCallback()
    func notificationsToObserve() -> [Notification.Name]
    func notificationClosureMap() -> NotificationClosureMap
    func didObserve(notification: Notification)
}

// MARK: Optional Protocol Methods

// If creating an abstract or base class, the base class must implement these explicitly
// in order for subclasses to override.

public extension NotificationObserver {
    func notificationsToObserve() -> [Notification.Name] {
        return []
    }

    func notificationClosureMap() -> NotificationClosureMap {
        return [:]
    }

    func didObserve(notification: Notification) {}
}

public extension NotificationObserver where Self: NSObject {
    func setupNotificationObserverCallback() {
        self.notificationsToObserve().forEach { notificationName in
            let notificationName = notificationName as NSNotification.Name
            NotificationCenter.default.add(observer: self,
                                           name: notificationName,
                                           action: { [weak self] notification in
                                               guard let self = self else { return }
                                               DispatchQueue.main.async {
                                                   self.didObserve(notification: notification as Notification)
                                               }
                                           })
        }

        self.notificationClosureMap().forEach { mappedNotification in

            NotificationCenter.default.add(observer: self,
                                           name: mappedNotification.key,
                                           action: { [weak self] notification in
                                               guard self != nil else { return }
                                               DispatchQueue.main.async {
                                                   mappedNotification.value(notification as Notification)
                                               }
                                           })
        }
    }
}

open class NotificationObserverMixin: InitializableMixin<NotificationObserver> {
    override open func initProperties() {
        mixable?.setupNotificationObserverCallback()
    }

    override open func willDeinit() {
        guard let mixable = self.mixable else { return }
        NotificationCenter.default.removeObserver(mixable)
    }
}
