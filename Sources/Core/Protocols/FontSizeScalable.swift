//
//  FontSizeScalable.swift
//  Pods
//
//  Created by Brian Strobach on 4/21/16.
//
//

import UIKit
import Swiftest

public protocol FontSizeScalable {
    var fontSize: CGFloat { get set}
    func scaleFontSizeForDevice()
}

extension UILabel: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = self.fontSize.scaledForDevice()
    }
}
extension UITextView: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = self.fontSize.scaledForDevice()
    }
}
extension UIButton: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = self.fontSize.scaledForDevice()
    }
}

extension UITextField: FontSizeScalable {   
    public func scaleFontSizeForDevice() {
        fontSize = self.fontSize.scaledForDevice()
    }
}

extension UIView {
    public func scaleSubviewFontSizesForDevice(excludingViews excludedViews: [UIView]? = nil) {
        let subviews = self.subviews
        
        if subviews.count == 0 {
            return
        }
        for view: UIView in subviews {
            if excludedViews?.contains(view) == true {
                continue
            }
            if let scalable = view as? FontSizeScalable {
                scalable.scaleFontSizeForDevice()
            } else {
                view.scaleSubviewFontSizesForDevice(excludingViews: excludedViews)
            }
        }
    }
}

extension Array where Element: FontSizeScalable {
    public func scaleFontSizesForDevice() {
        self.forEach { (fontScalable) in
            fontScalable.scaleFontSizeForDevice()
        }
    }
}

/**
 Assumes base size was set for iPhone 6, scales up or down from there accordingly.
 */

public extension DoubleConvertible {
    public func scaledForDevice(scaleDownOnly downOnly: Bool = true) -> CGFloat {
        let iPhone6ScreenHeight: CGFloat = 667.0
        let screenHeight = UIScreen.main.bounds.height
        let scaleRatio = screenHeight / iPhone6ScreenHeight
        if downOnly && scaleRatio > 1.0 {
            return self.double.cgFloat
        }
        return self.double.cgFloat * scaleRatio
    }
}
