//
//  FakeDataTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitBase
import UIKit

open class FakeDataTableViewController: DatasourceManagedTableViewController<Int>{
    
    open func registerReusables() {
        tableView.register(UITableViewCell.self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.add(models: Array(0...50))
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(indexPath)
        cell.textLabel?.text = dataSource[indexPath]?.string
        return cell
    }
}
