//
//  UITraitEnvironment+URL.swift
//  
//
//  Created by Brian Strobach on 9/28/22.
//

import Foundation
import UIKit
public extension UITraitEnvironment {
    func traitEnvironmentURL(light: URL, dark: URL, defaultToLight: Bool = true) -> URL {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                return light
            } else {
                return dark
            }
        } else {
            return defaultToLight ? light : dark
        }
    }
}

