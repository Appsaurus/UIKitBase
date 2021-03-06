//
//  StatefulViewControllerLoadingView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/5/15.
//  Copyright © 2015 Appsaurus. All rights reserved.
//
import UIKit
import UIKitTheme

open class StatefulViewControllerLoadingView: BaseView {
    override open func didMoveToWindow() {
        self.startLoadingAnimation()
    }

    deinit {
        stopLoadingAnimation()
    }

    open func startLoadingAnimation() {}

    open func stopLoadingAnimation() {}

    override open func style() {
        super.style()
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil {
            backgroundColor = .white
        }
    }
}
