//
//  FirstResponderManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class FirstResponderManagedMixin: UIViewControllerMixin<UIViewController & FirstResponderManaged> {
    
    open override func viewDidAppear(_ animated: Bool) {
        mixable.firstResponderManagedDidAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        mixable.firstResponderManagedWillDissappear()
    }
}
