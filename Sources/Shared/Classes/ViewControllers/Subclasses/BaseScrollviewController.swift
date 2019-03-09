//
//  BaseScrollviewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import UIKit

open class BaseScrollviewController: BaseViewController{
    
    open var scrollView: UIScrollView = ContainerScrollView(contentView: UIView())
    open var containerScrollView: ContainerScrollView{
        return scrollView as! ContainerScrollView
    }
    open var scrollViewContentView: UIView{
        return containerScrollView.contentView
    }
    
    fileprivate var additionalPaddingForScrollViewHeaderContent: CGFloat = 0.0
    fileprivate var expandContentSizeHeight: CGFloat = 0.0

    open override func createSubviews(){
        super.createAutoLayoutConstraints()
        view.addSubview(scrollView)
    }
    
    open override func createAutoLayoutConstraints(){
        super.createAutoLayoutConstraints()
        scrollView.pinToSuperview()
        scrollView.bringSubviewToFront(scrollViewContentView)
    }

    
}

