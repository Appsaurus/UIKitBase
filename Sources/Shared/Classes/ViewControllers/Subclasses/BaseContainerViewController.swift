//
//  BaseContainerViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 10/18/17.
//

import Foundation
import UIKit

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
    open lazy var containerViewLayoutInsets: UIEdgeInsets = .zero
    
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
        containerView.autoPinToSuperview(excludingEdges: [.top], withInsets: insets)

        
        guard let headerView = headerView else {
			containerView.autoPinToSuperview(edge: .top, withOffset: insets.top)
            return
        }
        
        headerView.autoPinToSuperview(excludingEdges: [.bottom], withInsets: insets)
        headerView.autoPin(edge: .bottom, toEdge: .top, of: containerView)
		headerView.autoEnforceContentSize()
    }
    
    open func createContainedViewLayoutConstraints(){
        if let containedView = containedView {
            containedView.autoPinToSuperview(excludingEdges: [.bottom])
            containedView.anchorBottom(equalTo: self.bottomLayoutGuide.topAnchor)
        }
    }
 }

