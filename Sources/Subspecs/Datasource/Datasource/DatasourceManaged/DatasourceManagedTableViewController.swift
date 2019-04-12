//
//  DatasourceManagedTableViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/12/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Swiftest

open class DatasourceManagedTableViewController<DM: Paginatable>: BaseTableViewController, DatasourceManaged {
    public typealias DatasourceModel = DM
    open override func createStatefulViews() -> StatefulViewMap {
        return .default
    }

    public var dataSource: CollectionDataSource<DatasourceModel> = CollectionDataSource<DatasourceModel>()
    open func createDataSource() -> CollectionDataSource<DatasourceModel> {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return CollectionDataSource<DatasourceModel>()
    }

    // MARK: UITableViewControllerDelegate/Datasource

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionCount
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(section: section)
    }
}
