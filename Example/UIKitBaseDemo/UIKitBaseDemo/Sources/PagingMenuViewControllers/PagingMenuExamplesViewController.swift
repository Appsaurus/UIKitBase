//
//  PagingMenuExamplesViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 2/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase

public class PagingMenuExamplesViewController: NavigationalMenuTableViewController{
    
    open override func initProperties() {
        super.initProperties()
        navigationBarStyle = .primaryContrast
    }

	override public func viewDidLoad() {
		super.viewDidLoad()
		addRow(title: "PagingMenuViewController", createDestinationVC: ExamplePagingMenuViewController())
		addRow(title: "Step Process PagingMenuViewController", createDestinationVC: ExampleStepProcessPagingMenuViewController())
		
	}
}
