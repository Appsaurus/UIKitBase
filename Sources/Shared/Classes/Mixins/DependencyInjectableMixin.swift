//
//  DependencyInjectableMixin.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class DependencyInjectableMixin: UIViewControllerMixin<DependencyInjectable>{
    open override func viewDidLoad() {
        mixable.assertDependencies()
    }
}

open class DependencyInjectableViewMixin: UIViewMixin<DependencyInjectable>{
    private var dependenciesConfirmed: Bool = false
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard dependenciesConfirmed else{
            mixable.assertDependencies()
            return
        }
    }
}
