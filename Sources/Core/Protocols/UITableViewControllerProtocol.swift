//
//  UITableViewControllerProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 9/14/16.
//
//

import Foundation
import UIKit

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
