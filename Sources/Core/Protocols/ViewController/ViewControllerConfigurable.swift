//
//  ViewControllerConfigurable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/29/18.
//

import UIKitMixinable
import UIKitTheme
import DarkMagic

public protocol ViewControllerConfigurable: OrientationLockable, StatusBarConfigurable, NavigationBarStyleable {
    var viewControllerConfiguration: ViewControllerConfiguration {get set}
}

private extension AssociatedObjectKeys {
    static let viewControllerConfiguration = AssociatedObjectKey<ViewControllerConfiguration>("viewControllerConfiguration")
}

public extension ViewControllerConfigurable where Self: UIViewController {
    
    public func applyBaseViewStyle() {
        self.view.apply(viewStyle: viewControllerConfiguration.style.viewStyle)
    }
    
    public var statusBarConfiguration: StatusBarConfiguration {
        return viewControllerConfiguration.statusBarConfiguration
    }
    
    public var viewControllerConfiguration: ViewControllerConfiguration {
        get {
            return self[.viewControllerConfiguration, .default]
        }
        set {
            self[.viewControllerConfiguration] = newValue
        }
    }
}

public extension ViewControllerConfigurable where Self: UIViewController {

    public var defaultOrientationLock: UIInterfaceOrientationMask? {
        return viewControllerConfiguration.orientationMask
    }
}
