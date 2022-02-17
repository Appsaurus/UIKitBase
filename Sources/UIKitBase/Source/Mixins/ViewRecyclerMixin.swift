//
//  ViewRecyclerMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

public class ViewRecyclerMixin: UIViewControllerMixin<ViewRecycler> {
    override open func viewDidLoad() {
        mixable?.registerReusables()
    }
}
