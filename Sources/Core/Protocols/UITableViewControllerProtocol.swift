//
//  UITableViewControllerProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 9/14/16.
//
//

import Foundation
import UIKit

public protocol UITableViewReferencing {
    var managedTableView: UITableView { get }
}

extension UITableViewController: UITableViewReferencing {
    public var managedTableView: UITableView {
        return tableView
    }
}
public typealias UITableViewControllerProtocol = UITableViewDelegate & UITableViewDataSource
public typealias UIPageViewControllerProtocol = UIPageViewControllerDelegate & UIPageViewControllerDataSource
public typealias UICollectionViewControllerProtocol = UICollectionViewDelegate & UICollectionViewDataSource

public extension UITableView {
    func setController<C: UITableViewControllerProtocol>(_ controller: C) {
        delegate = controller
        dataSource = controller
    }
}

public extension UICollectionView {
    func setController<C: UICollectionViewControllerProtocol>(_ controller: C) {
        delegate = controller
        dataSource = controller
    }
}
