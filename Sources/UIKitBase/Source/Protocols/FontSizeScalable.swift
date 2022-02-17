//
//  FontSizeScalable.swift
//  Pods
//
//  Created by Brian Strobach on 4/21/16.
//
//

import Swiftest
import UIKit

public protocol FontSizeScalable {
    var fontSize: CGFloat { get set }
    func scaleFontSizeForDevice()
}

extension UILabel: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = fontSize.scaledForDevice()
    }
}

extension UITextView: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = fontSize.scaledForDevice()
    }
}

extension UIButton: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = fontSize.scaledForDevice()
    }
}

extension UITextField: FontSizeScalable {
    public func scaleFontSizeForDevice() {
        fontSize = fontSize.scaledForDevice()
    }
}

public extension UIView {
    func scaleSubviewFontSizesForDevice(excludingViews excludedViews: [UIView]? = nil) {
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

public extension Array where Element: FontSizeScalable {
    func scaleFontSizesForDevice() {
        forEach { fontScalable in
            fontScalable.scaleFontSizeForDevice()
        }
    }
}

/**
 Assumes base size was set for iPhone 6, scales up or down from there accordingly.
 */

public enum FontScalingOption {
    case downOnly
    case upOnly
    case upAndDown
}

public extension DoubleConvertible {
    func scaledForDevice(baselineScreenHeight: CGFloat = 667.0, option: FontScalingOption = .downOnly) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let scaleRatio = screenHeight / baselineScreenHeight
        switch option {
        case .downOnly:
            if scaleRatio > 1.0 {
                return double.cgFloat
            }
        case .upOnly:
            if scaleRatio < 1.0 {
                return double.cgFloat
            }
        default: break
        }

        return double.cgFloat * scaleRatio
    }
}
