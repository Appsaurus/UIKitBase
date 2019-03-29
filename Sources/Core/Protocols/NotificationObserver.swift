//
//  NotificationObserver.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import UIKitMixinable
import UIKitExtensions
import Actions
public typealias NotificationClosure = (Notification) -> Void
public typealias NotificationClosureMap = [Notification.Name: NotificationClosure]

public protocol NotificationObserver: class {
	func setupNotificationObserverCallback()
    func notificationsToObserve() -> [Notification.Name]
    func notificationClosureMap() -> NotificationClosureMap
    func didObserve(notification: Notification)
}

// MARK: Optional Protocol Methods
//If creating an abstract or base class, the base class must implement these explicitly
//in order for subclasses to override.

extension NotificationObserver {
    public func notificationsToObserve() -> [Notification.Name] {
        return []
    }
    public func notificationClosureMap() -> NotificationClosureMap {
        return [:]
    }
    
    public func didObserve(notification: Notification) {
        
    }
}

extension NotificationObserver where Self: NSObject {

	public func setupNotificationObserverCallback() {
		notificationsToObserve().forEach { (notificationName) in
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
        
        notificationClosureMap().forEach { (mappedNotification) in
            
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
    open override func didInit() {
        mixable.setupNotificationObserverCallback()
    }
    open override func willDeinit() {
        NotificationCenter.default.removeObserver(mixable)
    }
}
