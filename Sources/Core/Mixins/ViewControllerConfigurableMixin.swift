//
//  ViewControllerConfigurableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

public class ViewControllerConfigurableMixin: UIViewControllerMixin<UIViewController & ViewControllerConfigurable> {
    open override func didInit() {
        mixable.navigationBarStyle = mixable.viewControllerConfiguration.style.navigationBarStyle
    }
}
