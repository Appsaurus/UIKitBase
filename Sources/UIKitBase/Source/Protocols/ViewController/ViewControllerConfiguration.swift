//
//  ViewControllerConfiguration.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/29/18.
//

import UIKitTheme

open class ViewControllerConfiguration {
    open var style: ViewControllerStyle
    open var orientationMask: UIInterfaceOrientationMask
    open var statusBarConfiguration: StatusBarConfiguration

    public required init(style: ViewControllerStyle = .default,
                         orientationMask: UIInterfaceOrientationMask = .default,
                         statusBarConfiguration: StatusBarConfiguration = .default)
    {
        self.style = style
        self.orientationMask = orientationMask
        self.statusBarConfiguration = statusBarConfiguration
    }

    public static var `default` = ViewControllerConfiguration()
}

public extension UIInterfaceOrientationMask {
    static var `default`: UIInterfaceOrientationMask {
        return App.configuration.orientation
    }
}
