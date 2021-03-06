//
//  ViewControllerConfigurableMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/30/18.
//

import UIKitMixinable

// See notes here: https://stackoverflow.com/questions/40243112/uinavigationbar-change-colors-on-push
public class ViewControllerConfigurableMixin: UIViewControllerMixin<UIViewController & ViewControllerConfigurable> {
    override open func viewWillAppear(_ animated: Bool) {
        mixable?.animateToDefaultNavigationBarStyle()
    }

    override open func viewDidLoad() {
        mixable?.applyDefaultNavigationBarStyle()
    }

    override open func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent == nil else { return }
        mixable?.animateToPreviousViewControllerNavigationBarStyle()
    }
}
