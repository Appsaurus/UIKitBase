//
//  PaginatableTableViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 2/7/17.
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import Swiftest
import UIKit
import UIKitExtensions

// open class PaginatableTableViewController<ModelType: Paginatable>: BaseTableViewController, PaginationManaged, AsyncDatasourceChangeManager {
//
//    open var asyncDatasourceChangeQueue: [AsyncDatasourceChange] = []
//    open var uponQueueCompletion: VoidClosure?
//    open lazy var dataSource: CollectionDataSource<ModelType> = CollectionDataSource<ModelType>()
//
//    open var prefetchedData: [ModelType]?
//    open var infiniteScrollable: Bool = true
//    open var refreshable: Bool = true
//    open var loadsResultsImmediately: Bool = true
//    open var appendsIndexPathsOnInfinityScroll: Bool = true
//    open var scrollDirection: InfinityScrollDirection {
//        return .vertical
//    }
//
//    // MARK: PaginationManaged
//
//    open lazy var paginator: Paginator<ModelType> = {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        return Paginator<ModelType>()
//    }()
//
//    open lazy var activePaginator: Paginator<ModelType> = self.paginator
//    open lazy var fallbackPaginator: Paginator<ModelType>? = nil
//
//    open func refreshDidFail(with error: Error) {
//        showError(error: error)
//        debugLog(error)
//    }
//
//    open func loadMoreDidFail(with error: Error) {
//        showError(error: error)
//        debugLog(error)
//    }
//
//    open override func createSubviews() {
//        super.createSubviews()
//        setupPaginatable()
//    }
//
//    open override func startLoading() {
//        super.startLoading()
//        startLoadingData()
//    }
//
//    deinit {
//        if tableView != nil {
//            tableView.loadingControls.clear()
//        }
//    }
//
//    open func didReload() {}
//
//    open override func didTransition(to state: State) {
//        updatePaginatableViews(for: state)
//    }
// }
