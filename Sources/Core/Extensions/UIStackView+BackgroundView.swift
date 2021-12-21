//
//  UIStackView+BackgroundView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Layman
import UIKit

private let tag = 9999
public extension UIStackView {
    func addBackgroundView(color: UIColor? = nil) -> UIView {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.tag = tag
        insertSubview(subView, at: 0)
        subView.pinToSuperview()
        subView.forceAutolayoutPass()
        return subView
    }

    var backgroundView: UIView {
        return viewWithTag(tag) ?? self.addBackgroundView()
    }
}
