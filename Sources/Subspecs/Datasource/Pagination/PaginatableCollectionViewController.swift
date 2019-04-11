////
////  PaginatableCollectionViewController.swift
////  Pods
////
////  Created by Brian Strobach on 3/16/17.
////
////
//
// import Swiftest
//
// open class PaginatableCollectionViewController<ModelType: Equatable>: DatasourceManagedCollectionViewController<ModelType>, PaginationManaged {
//    var dependencyEntityId: String?
//    public var prefetchedData: [ModelType]?
//    open var infiniteScrollable: Bool = true
//    open var refreshable: Bool = true
//    open var loadsResultsImmediately: Bool = true
//    open var appendsIndexPathsOnInfinityScroll: Bool = true
//    open var scrollDirection: InfinityScrollDirection {
//        return .vertical
//    }
//
//    // AsyncStateManagementQueue
//    open var asyncDatasourceChangeQueue: [AsyncDatasourceChange] = []
//    open var uponQueueCompletion: VoidClosure?
//
//    open lazy var activePaginator: Paginator<ModelType> = self.paginator
//
//    open lazy var paginator: Paginator<ModelType> = {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        return Paginator<ModelType>()
//    }()
//
//    open lazy var fallbackPaginator: Paginator<ModelType>? = nil
//
//    // MARK: StatefulProtocol
//
//    open var statefulSuperview: UIView {
//        return collectionView ?? UIView()
//    }
//
//    open override func createStatefulViews() -> StatefulViewMap {
//        return .default
//    }
//
//    open func refreshDidFail(with: Error) {}
//
//    open func loadMoreDidFail(with: Error) {}
//
//    open override func createSubviews() {
//        super.createSubviews()
//        setupPaginatable()
//    }
//
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        startLoadingData()
//    }
//
//    deinit {
//        collectionView?.loadingControls.clear()
//    }
//
//    open func didReload() {}
//
//    // MARK: UITableViewControllerDelegate/Datasource
//
//    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return dataSource.sectionCount
//    }
//
//    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.numberOfItems(section: section)
//    }
//
//    open override func didTransition(to state: State) {
//        updatePaginatableViews(for: state)
//    }
// }
