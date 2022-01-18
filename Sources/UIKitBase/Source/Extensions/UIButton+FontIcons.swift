//
//  UIButton+FontIcons.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIFontIcons
import UIKit

public extension UIButton {
    func setTitle<F: FontIconEnum>(icon: F,
                                   size: CGFloat? = nil,
                                   color: UIColor? = nil,
                                   for state: UIControl.State = .normal)
    {
        if let label = titleLabel {
            let pointSize = size ?? label.font.pointSize
            let font = icon.getFont(pointSize)
            label.font = font
            if let titleColor = color {
                setTitleColor(titleColor, for: state)
            }
            self.setTitle(icon.rawValue, for: state)
        }
    }

    func setImage<F: FontIconEnum>(icon: F,
                                   with style: FontIconStyle = FontIconStyle(),
                                   fillPercentOfFrame: CGFloat = 0.5,
                                   for state: UIControl.State = .normal)
    {
        if let imageView = imageView {
            self.setImage(imageView.iconImageThatFits(icon, style: style, fillPercentOfFrame: fillPercentOfFrame), for: state)
        }
    }
}
