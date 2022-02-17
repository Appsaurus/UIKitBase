//
//  KeyboardSizeAwareMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

public class KeyboardSizeAwareMixin: UIViewControllerMixin<UIViewController & KeyboardSizeAware> {
    override open func viewWillAppear(_ animated: Bool) {
        mixable?.registerKeyboard()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        mixable?.deregisterKeyboard()
    }
}
