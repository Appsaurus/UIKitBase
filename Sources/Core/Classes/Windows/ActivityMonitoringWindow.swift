//
//  ActivityMonitoringWindow.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/29/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import UIKit

// Custom window that monitors user interactionw with the app
open class ActivityMonitoringWindow: UIWindow {
    // record the timestamp of the latest touch
    open var lastTouched = Date()

    // Indicates whether the app has been touched within the dormant timemout period.
    open var dormant: Bool {
        return Date().timeIntervalSince(lastTouched) > dormantTimeout
    }

    // Time until the window is considered dormant.
    open var dormantTimeout: TimeInterval = 5

    override open func sendEvent(_ event: UIEvent) {
        self.updateLastTouchedTimestamp()
        super.sendEvent(event)
    }

    open func updateLastTouchedTimestamp() {
        self.lastTouched = Date()
    }
}
