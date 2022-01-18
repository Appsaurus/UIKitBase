//
//  InitialAutoLayoutPassAware.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import DarkMagic
import Foundation

public protocol InitialAutoLayoutPassAware: AnyObject {
    var didInitialAutolayoutPass: Bool { get set }
    func didFinishInitialAutoLayoutPass()
}

private extension AssociatedObjectKeys {
    static let didInitialAutolayoutPass = AssociatedObjectKey<Bool>("didInitialAutolayoutPass")
}

public extension InitialAutoLayoutPassAware where Self: NSObject {
    var didInitialAutolayoutPass: Bool {
        get {
            return self[.didInitialAutolayoutPass, false]
        }
        set {
            self[.didInitialAutolayoutPass] = newValue
        }
    }
}
