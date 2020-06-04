//
//  CollapsibleLayoutConstraint.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 2/5/16.
//  Copyright © 2016 Appsaurus. All rights reserved.
//

import UIKit

open class CollapsibleLayoutConstraint: NSLayoutConstraint {
    open var expandedConstant: CGFloat = 0.0
    override open var constant: CGFloat {
        get {
            return super.constant
        }
        set {
            super.constant = newValue
            if constant > 0.0 {
                expandedConstant = constant
            }
        }
    }

    override open func awakeFromNib() {
        self.expandedConstant = self.constant
    }

    open func collapse() {
        self.constant = 0.0
    }

    open func expand() {
        self.constant = self.expandedConstant
    }
}

public extension UIView {
    // TODO: Add animated collapsing/expanding and func that autocollapses/expands when view is hidden/visible
    func collapseConstraints() {
        for constraint in constraints {
            if let collapsible = constraint as? CollapsibleLayoutConstraint {
                collapsible.collapse()
            }
        }
    }

    func expandConstraints() {
        for constraint in constraints {
            if let collapsible = constraint as? CollapsibleLayoutConstraint {
                collapsible.expand()
            }
        }
    }
}
