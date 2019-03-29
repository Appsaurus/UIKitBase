//
//  OrientationLockable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKit
import DarkMagic

public protocol OrientationLockable: class {
    var temporaryOrientationLock: UIInterfaceOrientationMask? { get set }
    var defaultSupportedOrientations: UIInterfaceOrientationMask? { get set }
}
private extension AssociatedObjectKeys {
    static let temporaryOrientationLock = AssociatedObjectKey<UIInterfaceOrientationMask>("temporaryOrientationLock")
    static let defaultSupportedOrientations = AssociatedObjectKey<UIInterfaceOrientationMask>("defaultSupportedOrientations")
}

public extension OrientationLockable where Self: UIViewController {
    
    public var defaultSupportedOrientations: UIInterfaceOrientationMask? {
        get {
            return self[.defaultSupportedOrientations]
        }
        set {
            self[.defaultSupportedOrientations] = newValue
        }
    }
    
    public var temporaryOrientationLock: UIInterfaceOrientationMask? {
        get {
            return self[.temporaryOrientationLock]
        }
        set {
            self[.temporaryOrientationLock] = newValue
        }
    }
    
    public var currentSupportedInterfaceOrientation: UIInterfaceOrientationMask {
        return temporaryOrientationLock ?? defaultSupportedOrientations ?? .default
    }
    
}
