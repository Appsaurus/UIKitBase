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
    public func setController<C: UITableViewControllerProtocol>(_ controller: C) {
        self.delegate = controller
        self.dataSource = controller
    }
}

public extension UICollectionView {
    public func setController<C: UICollectionViewControllerProtocol>(_ controller: C) {
        self.delegate = controller
        self.dataSource = controller
    }
}
