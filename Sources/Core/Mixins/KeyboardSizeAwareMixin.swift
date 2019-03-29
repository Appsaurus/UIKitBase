//
//  KeyboardSizeAwareMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

public class KeyboardSizeAwareMixin: UIViewControllerMixin<UIViewController & KeyboardSizeAware> {
    open override func viewWillAppear(_ animated: Bool) {
        mixable.registerKeyboard()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        mixable.deregisterKeyboard()
    }
}
