//
//  TableViewHeaderExampleViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitBase
import UIKit

open class TableViewHeaderExampleViewController: FakeDataTableViewController{
    
    open override func didInit() {
        super.didInit()
        extendViewUnderNavigationBar()
        navigationBarStyle = .transparent
    }
 
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        setupScrollViewHeader()
    }
    
    
    open func createSubheaderView() -> UIView?{
        return nil
    }
    
    open override func startLoading() {
        super.startLoading()
        displayScrollViewHeaderExampleContent()
    }
    
}

extension TableViewHeaderExampleViewController: ScrollViewHeaderAdornable{
//    public typealias SVH = ScrollViewHeader
    public func createScrollViewHeader() -> ScrollViewHeader {
        return createExampleScrollViewHeader(subheaderView: createSubheaderView())
    }
}
