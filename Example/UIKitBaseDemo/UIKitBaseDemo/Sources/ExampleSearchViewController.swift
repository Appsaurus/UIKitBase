//
//  ExampleSearchViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 10/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase


open class ExampleSearchViewController: SearchViewController<ExampleObject>{
    open override lazy var searchDataSource: SearchDataSource = .localDatasource
    open override lazy var searchBarPosition: SearchBarPosition = .navigationTitle
    open override lazy var searchResultsTableViewController: PaginatableTableViewController<ExampleObject> = ExamplePaginatableTableViewController()
    
}
