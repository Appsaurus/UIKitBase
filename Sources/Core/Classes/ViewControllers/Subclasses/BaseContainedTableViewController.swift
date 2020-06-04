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
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseTableViewControllerProtocolMixins
    }

    open lazy var tableViewStyle: UITableView.Style = .grouped
    open lazy var tableView: UITableView = UITableView(frame: .zero, style: self.tableViewStyle).then { tv in
        tv.backgroundColor = .clear
    }

    override open func initProperties() {
        super.initProperties()
        containedView = self.tableView
    }

    override open func setupDelegates() {
        super.setupDelegates()
        self.tableView.delegate = self
    }
}
