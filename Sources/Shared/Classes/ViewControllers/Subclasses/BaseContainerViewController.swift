//
//  BaseContainerViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 10/18/17.
//

import Foundation
import UIKit
import Layman

open class BaseContainerViewController: BaseViewController {
    
    open lazy var headerView: UIView? = {
        return self.createHeaderView()
    }()
   
    
    /// Hook to create a static header view that is pinned above the containerview.
    ///
    /// - Returns: Header view, height determined by subview autolayout constraints
    open func createHeaderView() -> UIView?{
        return nil
    }
    
    open lazy var containerView: UIView = UIView()
    open lazy var containedView: UIView? = nil
    open lazy var containerViewLayoutInsets: LayoutPadding = .zero
    
    open override func createSubviews(){
        super.createSubviews()
        view.addSubview(containerView)        
        
        if let containedView = containedView {
            containerView.addSubview(containedView)
        }
        
        guard let headerView = headerView else { return }
        view.addSubview(headerView)
    }

    open override func createAutoLayoutConstraints(){
        super.createAutoLayoutConstraints()
        createContainerViewLayoutConstraints()
    }

    open func createContainerViewLayoutConstraints(){
        createContainedViewLayoutConstraints()
        let insets = containerViewLayoutInsets
        containerView.equal(to: edges.excluding(.top).inset(insets))

        
        guard let headerView = headerView else {
			containerView.equal(to: top.inset(insets.top))
            return
        }

        headerView.equal(to: edges.excluding(.bottom).inset(insets))
        headerView.bottom.equal(to: containerView.top)
		headerView.enforceContentSize()
    }
    
    open func createContainedViewLayoutConstraints(){
        if let containedView = containedView {
            containedView.equal(to: containerView.edges.excluding(.bottom))
            containedView.equal(to: bottom)
        }
    }
 }

