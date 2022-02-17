//
//  InitialAutoLayoutPassAwareMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class InitialAutoLayoutPassAwareMixin: UIViewMixin<InitialAutoLayoutPassAware> {
    override open func layoutSubviews() {
        guard let mixable = self.mixable else { return }
        if !mixable.didInitialAutolayoutPass {
            mixable.didInitialAutolayoutPass = true
            mixable.didFinishInitialAutoLayoutPass()
        }
    }
}

open class InitialAutoLayoutPassAwareViewControllerMixin: UIViewControllerMixin<InitialAutoLayoutPassAware> {
    override open func viewDidLayoutSubviews() {
        guard let mixable = self.mixable else { return }
        if !mixable.didInitialAutolayoutPass {
            mixable.didInitialAutolayoutPass = true
            mixable.didFinishInitialAutoLayoutPass()
        }
    }
}
