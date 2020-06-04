//
//  DependencyInjectableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class DependencyInjectableMixin: UIViewControllerMixin<DependencyInjectable> {
    override open func viewDidLoad() {
        mixable.assertDependencies()
    }
}

open class DependencyInjectableViewMixin: UIViewMixin<DependencyInjectable> {
    private var dependenciesConfirmed: Bool = false

    override open func layoutSubviews() {
        super.layoutSubviews()
        guard self.dependenciesConfirmed else {
            mixable.assertDependencies()
            return
        }
    }
}
