//
//  AppStyleGuideExtensions.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 11/15/18.
//

import Foundation
import UIKitTheme

extension AppStyleGuide {
//    TODO: Refactor into style classes
// MARK: Badge View Styles
        open func badgeViewStyle(for badgeStyle: BadgeStyle) -> ViewStyle {
            let style = ViewStyle(backgroundColor: .primary, shape: .rounded)
            switch badgeStyle {
            case .notification, .error, .delete:
                style.backgroundColor = .error
            case .primary:
                style.backgroundColor = .primary
            case .primaryContrast:
                style.backgroundColor = .primaryContrast
            case .warning:
                style.backgroundColor = .warning
            case .additive:
                style.backgroundColor = .success
            }
            return style
        }
    
        open func badgeTextStyle(for badgeStyle: BadgeStyle, fontSize: CGFloat? = nil) -> TextStyle {
    
            let font: UIFont = fontSize != nil ? UIFont.regular(fontSize!) : UIFont.regular()
            let style = TextStyle(color: .primaryContrast, font: font)
            switch badgeStyle {
            case .notification, .primaryContrast, .warning, .additive, .error, .delete:
                style.color = .primary
            case .primary:
                style.color = .primaryContrast
            }
            return style
        }
}
