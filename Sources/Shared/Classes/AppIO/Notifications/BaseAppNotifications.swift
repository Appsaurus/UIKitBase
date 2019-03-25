//
//  BaseAppNotifications.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/22/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Foundation
import Swiftest
import UserNotifications

public typealias AppNotificationPayload = [AnyHashable : Any]

public enum AppNotificationOrigin{
    case local, remote
}

open class BaseAppNotification{
    open var payload: AppNotificationPayload = [:]
    open var origin: AppNotificationOrigin

    // Workaround for lack of @available on stored properties
    private var _unNotification: AnyObject?
    @available(iOS 10.0, *)
    open var unNotification: UNNotification? {
        get {
            return _unNotification as? UNNotification
        }
        set {
            _unNotification = newValue
        }
    }

    @available(iOS 10.0, *)
    public init(unNotification: UNNotification) {
        self._unNotification = unNotification
        let request = unNotification.request
        self.payload = request.content.userInfo
        self.origin = request.trigger is UNPushNotificationTrigger ? .remote : .local
    }

    public init(payload: AppNotificationPayload, origin: AppNotificationOrigin = .remote) {
        self.payload = payload
        self.origin = origin
    }

}
open class AppNotification<ID: AppNotificationID> : BaseAppNotification{


    open var notificationIdentifier: ID?
    open var notificationCenterNotification: Notification?{
        guard let name = notificationIdentifier?.notificationCenterName() else { return nil }
        return Notification(name: name, object: self, userInfo: payload)
    }

    @available(iOS 10.0, *)
    public required init(unNotification: UNNotification, idKey: String = "notificationId") {
        super.init(unNotification: unNotification)
        guard let notificationStringId = payload[idKey] as? String else{
            return
        }
        self.notificationIdentifier = ID.from(id: notificationStringId)
    }

    public required init(payload: AppNotificationPayload, origin: AppNotificationOrigin = .remote, idKey: String = "notificationId") {
        super.init(payload: payload, origin: origin)
        guard let notificationStringId = payload[idKey] as? String else{
            return
        }
        self.notificationIdentifier = ID.from(id: notificationStringId)
    }

    public convenience init(notification: BaseAppNotification, idKey: String = "notificationId") {
        self.init(payload: notification.payload, origin: notification.origin, idKey: idKey)
    }

}

public protocol AppNotificationID: StringIdentifiableEnum{}



public protocol StringIdentifiableEnum: CaseIterable, RawRepresentable, Equatable{
    var rawValue: String { get }
    static func from(id: String) -> Self?
    func notificationCenterName() -> Notification.Name
}

extension StringIdentifiableEnum{
    //Convenience for when rawValues don't match labels.
    public static func from(id: String) -> Self?{
        return allCases.first { (enumCase) -> Bool in
            "\(enumCase)" == id
        }
    }

    public func notificationCenterName() -> Notification.Name{
        return Notification.Name("\(rawValue)")
    }
}
