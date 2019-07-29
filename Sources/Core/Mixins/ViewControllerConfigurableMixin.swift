//
//  ViewControllerConfigurableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

public class ViewControllerConfigurableMixin: UIViewControllerMixin<UIViewController & ViewControllerConfigurable> {
    open override func viewWillAppear(_ animated: Bool) {
        mixable.animateToDefaultNavigationBarStyle()
    }

    open override func viewDidAppear(_ animated: Bool) {
        mixable.applyDefaultNavigationBarStyle()
    }
}
