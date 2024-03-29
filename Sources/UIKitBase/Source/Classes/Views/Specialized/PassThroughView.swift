//
//  PassThroughView.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 10/31/15.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import Layman
import Swiftest
import UIKitTheme

open class PassThroughView: BaseStatefulView, PassThroughTouchable {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return shouldPassThroughTouch(inside: point, with: event)
    }
}

public protocol PassThroughTouchable {
    func shouldPassThroughTouch(inside point: CGPoint, with event: UIEvent?) -> Bool
}

public extension PassThroughTouchable where Self: UIView {
    func shouldPassThroughTouch(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview: UIView in subviews {
            if !subview.isHidden, subview.alpha > 0, subview.isUserInteractionEnabled, subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
