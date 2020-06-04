//
//  OrientationLockable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import DarkMagic
import UIKit

public protocol OrientationLockable: AnyObject {
    var temporaryOrientationLock: UIInterfaceOrientationMask? { get set }
    var defaultSupportedOrientations: UIInterfaceOrientationMask? { get set }
}

private extension AssociatedObjectKeys {
    static let temporaryOrientationLock = AssociatedObjectKey<UIInterfaceOrientationMask>("temporaryOrientationLock")
    static let defaultSupportedOrientations = AssociatedObjectKey<UIInterfaceOrientationMask>("defaultSupportedOrientations")
}

public extension OrientationLockable where Self: UIViewController {
    var defaultSupportedOrientations: UIInterfaceOrientationMask? {
        get {
            return self[.defaultSupportedOrientations]
        }
        set {
            self[.defaultSupportedOrientations] = newValue
        }
    }

    var temporaryOrientationLock: UIInterfaceOrientationMask? {
        get {
            return self[.temporaryOrientationLock]
        }
        set {
            self[.temporaryOrientationLock] = newValue
        }
    }

    var currentSupportedInterfaceOrientation: UIInterfaceOrientationMask {
        return self.temporaryOrientationLock ?? self.defaultSupportedOrientations ?? .default
    }
}
