//
//  AnimatableTextField.swift
//  Pods
//
//  Created by Brian Strobach on 10/1/17.
//
//

import UIKit

open class AnimatableTextFieldConfiguration {}

open class AnimatableTextField: StatefulTextField {
    open var titleLabel = UILabel()
    open var secondaryLabel = UILabel()
    open var leftViewWidth: CGFloat = 0.0
    open var layoutHeights: (titleLabel: CGFloat, textField: CGFloat, secondaryLabel: CGFloat) = (17.0, 34.0, 17.0)

    /// Sync up textAlignment of all labels
    override open var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set(value) {
            super.textAlignment = value
            titleLabel.textAlignment = value
            secondaryLabel.textAlignment = value
        }
    }

    /// EdgeInsets for text.
    open var textInset: CGFloat = 0
    /*
     open override func textRect(forBounds bounds: CGRect) -> CGRect {
         var b = super.textRect(forBounds: bounds)
         b.origin.x += textInset
         b.size.width -= textInset
         return b
     }

     open override func editingRect(forBounds bounds: CGRect) -> CGRect {
         return textRect(forBounds: bounds)
     }
     */

    override open func layoutSubviews(for state: TextFieldState) {
        super.layoutSubviews(for: state)
        self.layoutTitleLabel()
    }

    open func layoutTitleLabel() {}
}
