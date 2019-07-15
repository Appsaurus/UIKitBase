//
//  PaginationManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/15/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

open class PaginationManagedMixin<VC: UIViewController & PaginationManaged>: DatasourceManagedMixin<VC> {

    open override func viewDidLoad() {
        super.viewDidLoad()
        mixable.onDidTransitionMixins.append { [weak mixable] state in
            guard let mixable = mixable else { return }
            mixable.updatePaginatableViews(for: state)
        }
    }

    open override func willDeinit() {
        super.willDeinit()
        mixable.datasourceManagedView.loadingControls.clear()
    }

    open override func createSubviews() {
        super.createSubviews()
        mixable.setupPaginatable()
    }

    open override func loadAsyncData() {
        super.loadAsyncData()
        mixable.startLoadingData()
    }
}


//open class PaginatableTableViewMixin<TVC: UITableViewController & PaginationManaged>: PaginationManagedMixin<TVC>
//    where TVC.Datasource: UITableViewDataSource{
//
//    open override func setupDelegates() {
//        super.setupDelegates()
//        mixable.tableView.dataSource = mixable.datasource
//    }
//}
//
//
//open class PaginatableCollectionViewMixin<CVC: UICollectionViewController & PaginationManaged>: PaginationManagedMixin<CVC>
//    where CVC.Datasource: UICollectionViewDataSource{
//    open override func setupDelegates() {
//        mixable.collectionView.dataSource = mixable.datasource
//    }
//}
