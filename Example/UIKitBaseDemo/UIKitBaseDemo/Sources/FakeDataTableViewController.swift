//
//  FakeDataTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitBase
import UIKit
import DiffableDataSources

open class FakeDataTableViewController: BaseTableViewController, DatasourceManaged{

    open func registerReusables() {
        tableView.register(UITableViewCell.self)
    }

    public lazy var datasource = TableViewDatasource<Int>(tableView: tableView) { tableView, indexPath, model in
        let cell: UITableViewCell = tableView.dequeueReusableCell(indexPath)
        cell.textLabel?.text = "\(model)"
        return cell
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        datasource.add(models: Array(0...50))
    }

}
