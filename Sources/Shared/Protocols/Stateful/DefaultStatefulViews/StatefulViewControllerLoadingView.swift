//
//  StatefulViewControllerEmptyView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/5/15.
//  Copyright © 2015 Appsaurus. All rights reserved.
//
import UIKit
import UIKitTheme

open class StatefulViewControllerLoadingView: StatefulViewControllerView {

	
    open override func didMoveToWindow() {
        startLoadingAnimation()
    }
    
    deinit {
        stopLoadingAnimation()
    }
    open func startLoadingAnimation(){

    }
    open func stopLoadingAnimation(){

    }
    
    open override func style() {
        super.style()
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? self.parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil{
            backgroundColor = .white
        }
    }
    
}
