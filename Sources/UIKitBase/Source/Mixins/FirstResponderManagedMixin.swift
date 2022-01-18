//
//  FirstResponderManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class FirstResponderManagedMixin: UIViewControllerMixin<UIViewController & FirstResponderManaged> {
    override open func viewWillAppear(_ animated: Bool) {
        mixable?.firstResponderManagedWillAppear()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        mixable?.firstResponderManagedWillDissappear()
    }
}
