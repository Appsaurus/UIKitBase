//
//  ScrollViewParentHeaderExampleViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//


import UIKitTheme
import UIKitBase
import UIKitBase

open class ScrollViewParentHeaderExampleViewController: BaseScrollviewParentViewController{
    
    open var includeSubheader: Bool = false
    
    public init(includeSubheader: Bool = false) {
        self.includeSubheader = includeSubheader
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func initialChildViewController() -> UIViewController {
        return FakeDataTableViewController()
    }
    open override func initProperties() {
        super.initProperties()
        extendViewUnderNavigationBar()
    }
    
    open var defaultNavigationBarStyle: NavigationBarStyle? {
        return .transparent
    }
    
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        setupScrollViewHeader()
    }
    
    open override func startLoading() {        
        displayScrollViewHeaderExampleContent()
//        headerContentDidChange()
    }
    
    
    open func createSubheaderView() -> UIView?{
        return nil
    }
    
}

extension ScrollViewParentHeaderExampleViewController: ScrollViewHeaderAdornable{
//    public typealias SVH = ScrollViewHeader
    open func createScrollViewHeader() -> ScrollViewHeader {
        return createExampleScrollViewHeader(subheaderView: includeSubheader ? createExampleSubheaderView() : nil)
    }

}
