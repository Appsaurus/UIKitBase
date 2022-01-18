//
//  PaginationManager.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/15/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Layman
import Swiftest

open class PaginationConfiguration {
    open var infiniteScrollable: Bool = true
    open var refreshable: Bool = true
    open var loadsResultsImmediately: Bool = true
    open var scrollDirection: ScrollDirection = .vertical
    open var animatesDatasourceChanges: Bool = false
}

//
// open class PaginatorGroup<Model: Paginatable> {
//    open var paginator: Paginator<Model> = Paginator<Model>()
//    open lazy var activePaginator: Paginator<Model> = self.paginator
//    open var fallbackPaginator: Paginator<Model>?
//
//    open func reset() {
//        paginator.reset()
//        fallbackPaginator?.reset()
//        activePaginator = paginator
//    }
// }
//
// open class PaginationManager<Model: Paginatable> {
//    open var config = PaginationConfiguration()
//    open var paginators = PaginatorGroup<Model>()
//    open var datasource = CollectionDataSource<Model>()
//
//    open func reset() {
//        datasource.reset()
//        paginators.reset()
//    }
// }
