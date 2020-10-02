//
//  PaginationManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/15/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import DarkMagic
import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

open class PaginationManagedMixin<VC: UIViewController & PaginationManaged>: DatasourceManagedMixin<VC> {
    override open func viewDidLoad() {
        super.viewDidLoad()
        guard let mixable = self.mixable else { return }
        mixable.onDidTransitionMixins.append { [weak mixable] state in
            guard let mixable = mixable else { return }
            mixable.updatePaginatableViews(for: state)
        }
        mixable.reloadFunction = { [weak self] completion in
            guard let self = self else { return }
            self.mixable?.fetchNextPage(firstPage: true,
                                        transitioningState: .loading,
                                        reloadCompletion: { completion() })
        }
    }

    override open func willDeinit() {
        super.willDeinit()
        mixable?.datasourceManagedView.loadingControls.clear()
    }

    override open func createSubviews() {
        super.createSubviews()
        mixable?.setupPaginatable()
    }

    override open func loadAsyncData() {
        super.loadAsyncData()
        mixable?.startLoadingData()
    }
}

// open class PaginatableTableViewMixin<TVC: UITableViewController & PaginationManaged>: PaginationManagedMixin<TVC>
//    where TVC.Datasource: UITableViewDataSource{
//
//    open override func setupDelegates() {
//        super.setupDelegates()
//        mixable.tableView.dataSource = mixable.datasource
//    }
// }
//
//
// open class PaginatableCollectionViewMixin<CVC: UICollectionViewController & PaginationManaged>: PaginationManagedMixin<CVC>
//    where CVC.Datasource: UICollectionViewDataSource{
//    open override func setupDelegates() {
//        mixable.collectionView.dataSource = mixable.datasource
//    }
// }
