//
//  ScrollViewHeaderAdornableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/23/19.
//

import UIKitMixinable

open class ScrollViewHeaderAdornableMixin: UIViewControllerMixin<ScrollViewHeaderAdornable> {
    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        mixable?.setupScrollViewHeader()
    }
}
