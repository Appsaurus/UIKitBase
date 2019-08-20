//
//  ViewControllerConfigurableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

// See notes here: https://stackoverflow.com/questions/40243112/uinavigationbar-change-colors-on-push
public class ViewControllerConfigurableMixin: UIViewControllerMixin<UIViewController & ViewControllerConfigurable> {
    open override func viewWillAppear(_ animated: Bool) {
        mixable.animateToDefaultNavigationBarStyle()
    }

    open override func viewDidLoad() {
        mixable.applyDefaultNavigationBarStyle()
    }

    open override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent == nil else { return }
        mixable.animateToPreviousViewControllerNavigationBarStyle()
    }
}
