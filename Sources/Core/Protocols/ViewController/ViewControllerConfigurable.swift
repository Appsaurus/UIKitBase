//
//  ViewControllerConfigurable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/29/18.
//

import DarkMagic
import UIKitMixinable
import UIKitTheme

public protocol ViewControllerConfigurable: OrientationLockable, StatusBarConfigurable, NavigationBarStyleable {
    var viewControllerConfiguration: ViewControllerConfiguration { get set }
}

// public extension ViewControllerConfigurable where Self: UIViewController {
//    var navigationBarStyle: NavigationBarStyle? {
//        get {
//            return viewControllerConfiguration.style.navigationBarStyle
//        }
//        set {
//            viewControllerConfiguration.style.navigationBarStyle = newValue
/// /            applyDefaultNavigationBarStyle()
//        }
//    }
// }
private extension AssociatedObjectKeys {
    static let viewControllerConfiguration = AssociatedObjectKey<ViewControllerConfiguration>("viewControllerConfiguration")
}

public extension ViewControllerConfigurable where Self: UIViewController {
    func applyBaseViewStyle() {
        view.apply(viewStyle: viewControllerConfiguration.style.viewStyle)
    }

    var statusBarConfiguration: StatusBarConfiguration {
        return viewControllerConfiguration.statusBarConfiguration
    }

    var viewControllerConfiguration: ViewControllerConfiguration {
        get {
            return self[.viewControllerConfiguration, .default]
        }
        set {
            self[.viewControllerConfiguration] = newValue
        }
    }
}

public extension ViewControllerConfigurable where Self: UIViewController {
    var defaultOrientationLock: UIInterfaceOrientationMask? {
        return viewControllerConfiguration.orientationMask
    }
}
