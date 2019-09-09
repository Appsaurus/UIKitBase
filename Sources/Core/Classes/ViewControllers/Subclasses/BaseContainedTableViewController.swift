//
//  BaseContainedTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/20/17.

import Foundation
import UIKitMixinable

extension BaseTableViewControllerProtocol where Self: BaseContainedTableViewController {
    public var baseTableViewControllerProtocolMixins: [LifeCycle] {
        return baseViewControllerProtocolMixins
    }
}

open class BaseContainedTableViewController: BaseContainerViewController, BaseTableViewControllerProtocol, UITableViewDelegate {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewControllerProtocolMixins
    }

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
