//
//  InitialAutoLayoutPassAwareMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class InitialAutoLayoutPassAwareMixin: UIViewMixin<InitialAutoLayoutPassAware> {
    override open func layoutSubviews() {
        if !mixable.didInitialAutolayoutPass {
            mixable.didInitialAutolayoutPass = true
            mixable.didFinishInitialAutoLayoutPass()
        }
    }
}

open class InitialAutoLayoutPassAwareViewControllerMixin: UIViewControllerMixin<InitialAutoLayoutPassAware> {
    override open func viewDidLayoutSubviews() {
        if !mixable.didInitialAutolayoutPass {
            mixable.didInitialAutolayoutPass = true
            mixable.didFinishInitialAutoLayoutPass()
        }
    }
}
