//
//  ExampleSearchViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 10/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase


open class ExampleSearchViewController: SearchViewController {
    open override func initProperties() {
        super.initProperties()
        searchBarPosition = .navigationTitle
        searchResultsTableViewController = ExamplePaginatableTableViewController()
        searchResultsTableViewController.searchDataSourceType = .local
    }
    
}
