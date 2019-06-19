//
//  PaginationManaged.swift
//  Pods
//
//  Created by Brian Strobach on 3/16/17.
//
//

import DarkMagic
import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

public protocol PaginationManaged: StatefulViewController, DataSourceManaged, AsyncDatasourceChangeManager {
    associatedtype PaginatableModel: Paginatable
    typealias PM = PaginationManager<PaginatableModel>

    var paginationManager: PM { get set }
    var prefetchedData: [PaginatableModel]? { get set }
    var paginatableScrollView: UIScrollView { get }
    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator
    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator
    func infiniteScrollTriggered()
    func pullToRefreshTriggered()
    func setupPaginatable()

    func refreshDidFail(with error: Error)
    func loadMoreDidFail(with error: Error)
    func fetchNextPage(firstPage: Bool, transitioningState: State?, reloadCompletion: VoidClosure?)
    func didFinishFetching(error: Error)
    func didFinishFetching(result: PaginationResult<PaginatableModel>, isFirstPage: Bool, reloadCompletion: VoidClosure?)
    func reloadPaginatableCollectionView(stateAtCompletion: State?, completion: VoidClosure?)
    func reset(to initialState: State, completion: VoidClosure?)
    func reload()
    func didReload()
    func reloadDidBegin()
}

public typealias PaginatableTableViewController = BaseTableViewController & PaginationManaged
public typealias PaginatableCollectionViewController = BaseCollectionViewController & PaginationManaged

// MARK: CollectionDataSourceManaging

public extension PaginationManaged {
    func managedSectionCount() -> Int {
        return dataSource.sectionCount
    }

    func managedNumberOfItems(section: Int) -> Int {
        return dataSource.numberOfItems(section: section)
    }
}

private var associatedPaginationManager: String = "associatedPaginationManager"
private var associatedPrefetchedData: String = "associatedPrefetchedData"

public extension PaginationManaged where Self: NSObject {
    var paginationManager: PaginationManager<PaginatableModel> {
        get {
            return getAssociatedObject(for: &associatedPaginationManager, initialValue: PaginationManager<PaginatableModel>())
        }
        set {
            setAssociatedObject(newValue, for: &associatedPaginationManager)
        }
    }

    var prefetchedData: [PaginatableModel]? {
        get {
            return getAssociatedObject(for: &associatedPrefetchedData, initialValue: nil)
        }
        set {
            setAssociatedObject(newValue, for: &associatedPrefetchedData)
        }
    }
}

public extension PaginationManaged {
    var dataSource: CollectionDataSource<PaginatableModel> {
        get {
            return paginationManager.datasource
        }
        set {
            paginationManager.datasource = newValue
        }
    }

    var paginationConfig: PaginationConfiguration {
        get {
            return paginationManager.config
        }
        set {
            paginationManager.config = newValue
        }
    }

    var paginators: PaginatorGroup<PaginatableModel> {
        get {
            return paginationManager.paginators
        }
        set {
            paginationManager.paginators = newValue
        }
    }
}

public extension PaginationManaged where Self: UIViewController {
    func reset(to initialState: State = .initialized, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.paginationManager.reset()
            self.reloadPaginatableCollectionView(stateAtCompletion: initialState, completion: completion)
        }
    }

    func reload() {
        DispatchQueue.main.async {
            self.enqueue { [weak self] complete in
                self?.paginatableScrollView.hideNeedsLoadingIndicator()
                self?.reloadDidBegin()
                self?.fetchNextPage(firstPage: true, transitioningState: .loading, reloadCompletion: {
                    self?.didReload()
                    complete()
                })
            }
        }
    }

    func reloadPaginatableCollectionView(completion: @escaping VoidClosure) {
        reloadPaginatableCollectionView(stateAtCompletion: .loaded, completion: completion)
    }

    func reloadDidBegin() {}

    func didReload() {}

    func setupDefaultReloadControlsForEmptyState() {
        var retryTitle: String?
        if emptyView()?.responseButton.title(for: .normal).isNilOrEmpty == true {
            retryTitle = "Reload"
        }
        emptyView()?.set(responseButtonTitle: retryTitle, responseAction: reload)
    }

    func startLoadingData() {
        if paginationConfig.loadsResultsImmediately {
            if let prefetchedData = prefetchedData {
                if prefetchedData.count == 0 {
                    transition(to: .empty)
                } else {
                    didFinishFetching(result: (prefetchedData, true), isFirstPage: true)
                }
            } else {
                reload()
            }
        }
    }

    func infiniteScrollTriggered() {
        guard !paginators.activePaginator.hasLoadedAllPages else {
            debugLog("Triggered infinite scroll when there are no more pages to load.")
            return
        }
        enqueue { [weak self] completion in
            self?.fetchNextPage(firstPage: false, transitioningState: .loadingMore, reloadCompletion: completion)
        }
    }

    func pullToRefreshTriggered() {
        enqueue { [weak self] completion in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.paginatableScrollView.hideNeedsLoadingIndicator()
            }
            self.fetchNextPage(firstPage: true, transitioningState: .refreshing, reloadCompletion: completion)
        }
    }

    func fetchNextPage(firstPage: Bool = false, transitioningState: State? = .loading, reloadCompletion: VoidClosure? = nil) {
        if let state = transitioningState {
            transition(to: state)
        }
        let existingNextPage = !paginators.activePaginator.hasLoadedAllPages
        if firstPage { paginators.activePaginator.reset(stashingLastPageInfo: true) }
        paginators.activePaginator.fetchNextPage(success: { [weak self] items, isLastPage in
            DispatchQueue.main.async {
                self?.didFinishFetching(result: (items, isLastPage), isFirstPage: firstPage, reloadCompletion: reloadCompletion)
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.paginators.activePaginator.restoreLastPageInfo()
                self?.didFinishFetching(error: error)
                reloadCompletion?()
            }
        })
    }

    func didFinishFetching(result: PaginationResult<PaginatableModel>, isFirstPage: Bool = false, reloadCompletion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            if isFirstPage {
                if self.dataSource.rawModels.count > 0 {
                    self.dataSource.reset()
                }
                if result.items.count == 0 {
                    guard let fallbackPaginator = self.paginators.fallbackPaginator else {
                        self.reloadPaginatableCollectionView(stateAtCompletion: .empty, completion: reloadCompletion)
                        return
                    }
                    if self.paginators.activePaginator === fallbackPaginator {
                        self.reloadPaginatableCollectionView(stateAtCompletion: .empty, completion: reloadCompletion)
                        return
                    }
                    self.paginators.activePaginator = fallbackPaginator
                    self.fetchNextPage(firstPage: isFirstPage, transitioningState: self.currentState, reloadCompletion: reloadCompletion)
                    return
                }
            }
            self.dataSource.add(models: result.items)
            self.reloadPaginatableCollectionView(stateAtCompletion: result.isLastPage ? .loadedAll : .loaded, completion: reloadCompletion)
        }
    }

    func didFinishFetching(error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }
        guard currentState != .loadingMore else {
            transition(to: .loadMoreError)
            loadMoreDidFail(with: error)
            return
        }

        switch error {
        default:
            guard currentState != .refreshing else {
                transition(to: .refreshingError)
                refreshDidFail(with: error)
                return
            }
            errorView()?.set(message: "Error: \(error.localizedDescription)", responseButtonTitle: "Try again", responseAction: { [weak self] in
                guard let sSelf = self else { return }
                sSelf.fetchNextPage()
            })
            transition(to: .error)
        }
    }

    func refreshDidFail(with error: Error) {
        showError(error: error)
    }

    func loadMoreDidFail(with error: Error) {
        showError(error: error)
    }

    // TODO: Refactor to encapsulate this logic for each state and aviod massive switch
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func updatePaginatableViews(for state: State) {
        DispatchQueue.main.async {
            if state != .refreshing {
                self.paginatableScrollView.loadingControls.pullToRefresh.end()
            }

            switch state {
            case .initialized:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = false

            case .loading:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = false

            case .loadedAll:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = true

            case .loaded:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.paginatableScrollView.isScrollEnabled = true

            case .loadingMore:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = true

            case .refreshing:
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = true

            case .refreshingError:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.paginatableScrollView.isScrollEnabled = true
            case .empty:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = false
            case .error:
                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatableScrollView.isScrollEnabled = false
            default:
                break
            }

            if state != .loadingMore {
                self.paginatableScrollView.loadingControls.infiniteScroll.end()
            }
        }
    }

    func setupPaginatable() {
        if paginationConfig.refreshable {
            addPullToRefresh()
        }

        if paginationConfig.infiniteScrollable {
            addInfinityScroll()
        }
    }

    func setLoadingTriggers(enabled: Bool) {
        if paginationConfig.refreshable {
            addPullToRefresh()
        }

        if paginationConfig.infiniteScrollable {
            if #available(iOS 11.0, *) {
                paginatableScrollView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            paginatableScrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 275.0, right: 0.0)
            addInfinityScroll()

            paginatableScrollView.bounces = true
            paginatableScrollView.loadingControls.infiniteScroll.isStickToContent = true
        }
    }

    func addPullToRefresh() {
        paginatableScrollView.loadingControls.pullToRefresh.add(direction: paginationConfig.scrollDirection,
                                                                animator: createPullToRefreshAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.pullToRefreshTriggered()
            }
        }
    }

    func addInfinityScroll() {
        paginatableScrollView.loadingControls.infiniteScroll.add(direction: paginationConfig.scrollDirection,
                                                                 animator: createInfiniteScrollAnimator()) { [unowned self] in
            DispatchQueue.main.async {
                self.infiniteScrollTriggered()
            }
        }
    }

    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator {
        return DefaultRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    }

    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator {
        return CircleInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    }
}

public extension PaginationManaged where Self: BaseContainedTableViewController {
    var paginatableScrollView: UIScrollView {
        return tableView
    }

    func reloadPaginatableCollectionView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
        // https://stackoverflow.com/questions/27787552/ios-8-auto-height-cell-not-correct-height-at-first-load
        // Multiple reload calls fixes autolayout bug where dynamic cell height is incorrect on first load
        DispatchQueue.main.async {
            self.tableView.reloadData { [weak self] in
                self?.tableView.forceAutolayoutPass()
                if let state = stateAtCompletion { self?.transition(to: state) }
                completion?()
            }
        }
    }
}

public extension PaginationManaged where Self: UITableViewController {
    var paginatableScrollView: UIScrollView {
        return tableView
    }

    func reloadPaginatableCollectionView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.tableView.reloadData { [weak self] in
                self?.tableView.forceAutolayoutPass()
                if let state = stateAtCompletion { self?.transition(to: state) }
                completion?()
            }
        }
    }

    func removeCells(boundTo models: [PaginatableModel], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
        enqueue { [weak self] _ in
            guard let self = self else { return }
            let indexPathsToRemove = self.dataSource.removeAndReturnIndexes(models: models)
            if indexPathsToRemove.count > 0 {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: indexPathsToRemove, with: rowAnimation)
                self.tableView.endUpdates()
            }
        }
    }
}

public extension PaginationManaged where Self: UICollectionViewController {
    var paginatableScrollView: UIScrollView {
        return collectionView!
    }

    func reloadPaginatableCollectionView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.collectionView!.reloadData { [weak self] in
                self?.collectionView!.forceAutolayoutPass()
                if let state = stateAtCompletion { self?.transition(to: state) }
                completion?()
            }
        }
    }
}
