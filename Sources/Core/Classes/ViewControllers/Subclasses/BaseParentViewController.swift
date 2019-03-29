//
//  BaseParentViewController.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import Foundation
import UIKit
import Swiftest
import UIKitExtensions

open class BaseParentViewController: BaseContainerViewController {
    
    //If overridden to false, you must call loadChildViewController() explictly
    open func loadChildViewControllerImmediately() -> Bool{
        return true
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        if loadChildViewControllerImmediately(){
            loadChildViewController()
        }
    }
    
    open func loadChildViewController(){
		let child = initialChildViewController()
		if !children.contains(child){
			add(child, to: containerView)
			child.loadViewIfNeeded()

		}

    }

    open func initialChildViewController() -> UIViewController{
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }

	open override func viewWillDisappear(_ animated: Bool){
		super.viewWillDisappear(animated)
		if endsEditingOnDisappearance {
			containerView.endEditing(true)			
		}
	}

}
