//
//  DataSourceManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 7/15/19.
//

import Foundation
import UIKitMixinable
import Swiftest

public protocol DatasourceManaged {
    associatedtype Datasource: DiffableDatasource
    associatedtype DatasourceManagedView: UIScrollView

    var datasource: Datasource { get set }
    var datasourceManagedView: DatasourceManagedView { get }
    func setManagedDatasource()
}
public extension DatasourceManaged where Self: ScrollViewReferencing {
    var datasourceManagedView: UIScrollView {
        return scrollView
    }
}
//public extension DatasourceManaged where Self: BaseContainedTableViewController {
//    var datasourceManagedView: UITableView {
//        return tableView
//    }
//}
//
//public extension DatasourceManaged where Self: UITableViewController {
//    var datasourceManagedView: UITableView {
//        return tableView
//    }
//}
//
//public extension DatasourceManaged where Self: UICollectionViewController {
//    var datasourceManagedView: UICollectionView {
//        return collectionView!
//    }
//}
//
//public extension DatasourceManaged where Self: BaseContainedCollectionViewController {
//    var datasourceManagedView: UIScrollView {
//        return collectionView
//    }
//}

public extension DatasourceManaged where Self: UITableViewController, Datasource: UITableViewDataSource {
    func setManagedDatasource() {
        tableView.dataSource = datasource
    }
}

public extension DatasourceManaged where Self: BaseContainedTableViewController, Datasource: UITableViewDataSource {
    func setManagedDatasource() {
        tableView.dataSource = datasource
    }
}

public extension DatasourceManaged where Self: UICollectionViewController, Datasource: UICollectionViewDataSource {
    func setManagedDatasource() {
        collectionView.dataSource = datasource
    }
}

public extension DatasourceManaged where Self: BaseContainedCollectionViewController, Datasource: UICollectionViewDataSource {
    func setManagedDatasource() {
        collectionView.dataSource = datasource
    }
}

open class DatasourceManagedMixin<VC: DatasourceManaged>: UIViewControllerMixin<VC> {
    open override func setupDelegates() {
        super.setupDelegates()
        mixable.setManagedDatasource()
    }
}
