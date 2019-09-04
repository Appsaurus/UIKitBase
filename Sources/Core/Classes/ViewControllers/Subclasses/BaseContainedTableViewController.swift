//
//  BaseContainedTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/20/17.

import Foundation
import UIKitMixinable

open class BaseContainedTableViewController: BaseContainerViewController, BaseTableViewControllerProtocol, UITableViewDelegate {
    open lazy var tableViewStyle: UITableView.Style = .grouped
    open lazy var tableView: UITableView = UITableView(frame: .zero, style: self.tableViewStyle).then { tv in
        tv.backgroundColor = .clear
    }

    open override func initProperties() {
        super.initProperties()
        containedView = tableView
    }

    open override func setupDelegates() {
        super.setupDelegates()
        tableView.delegate = self
    }
}
