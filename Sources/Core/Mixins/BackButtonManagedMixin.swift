//
//  BackButtonManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIFontIcons
import UIKitMixinable

open class BackButtonManagedMixin: UIViewControllerMixin<BackButtonManaged> {
    open override func createSubviews() {
        mixable.createBackButton(icon: MaterialIcons.Arrow_Back)
    }
}
