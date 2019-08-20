//
//  PaginationManaged.swift
//  Pods
//
//  Created by Brian Strobach on 3/16/17.
//
//

import DarkMagic
import DiffableDataSources
import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

public typealias PaginatableTableViewController = BaseTableViewController & PaginationManaged
public typealias PaginatableCollectionViewController = BaseCollectionViewController & PaginationManaged

public protocol PaginationManaged: StatefulViewController, DatasourceManaged {
    typealias ItemIdentifierType = Datasource.ItemIdentifierType
    typealias SectionIdentifierType = Datasource.SectionIdentifierType

    var paginator: Paginator<ItemIdentifierType> { get set }
    var paginationConfig: PaginationConfiguration { get }
    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator
    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator
    func infiniteScrollTriggered()
    func pullToRefreshTriggered()
    func setupPaginatable()

    func refreshDidFail(with error: Error)
    func loadMoreDidFail(with error: Error)
    func fetchNextPage(firstPage: Bool, transitioningState: State?, reloadCompletion: VoidClosure?)
    func didFinishFetching(error: Error)
    func didFinishFetching(result: PaginationResult<ItemIdentifierType>, isFirstPage: Bool, reloadCompletion: VoidClosure?)
//    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure?)
    func reset(to initialState: State, completion: VoidClosure?)
    func reload(completion: @escaping VoidClosure)
    func reloadDidBegin()
    func didReload()
}

private var associatedPaginator: String = "associatedPaginator"
private var associatedPaginationConfig: String = "associatedPaginationConfig"

public extension PaginationManaged where Self: NSObject {
    var paginator: Paginator<ItemIdentifierType> {
        get {
            return getAssociatedObject(for: &associatedPaginator, initialValue: Paginator<ItemIdentifierType>())
        }
        set {
            setAssociatedObject(newValue, for: &associatedPaginator)
        }
    }

    var paginationConfig: PaginationConfiguration {
        get {
            return getAssociatedObject(for: &associatedPaginationConfig, initialValue: PaginationConfiguration())
        }
        set {
            setAssociatedObject(newValue, for: &associatedPaginationConfig)
        }
    }

    func reload() {
        reload(completion: {})
    }
}

public extension PaginationManaged where Self: UIViewController {
    func reset(to initialState: State = .initialized, completion: VoidClosure? = nil) {
        datasource.clearData(animated: false) { [weak self] in
            guard let self = self else { return }
            self.transition(to: initialState, animated: true, completion: completion)
        }
    }

    func reload(completion: @escaping VoidClosure) {
        datasourceManagedView.hideNeedsLoadingIndicator()
        reloadDidBegin()
        let reloadCompletion = { [weak self] in
            guard let self = self else { return }
            completion()
            self.didReload()
        }
        fetchNextPage(firstPage: true, reloadCompletion: reloadCompletion)
    }

//    func reloadPaginatableCollectionView(completion: @escaping VoidClosure) {
//        reloadPaginatingView(stateAtCompletion: .loaded, completion: completion)
//    }

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
            reload()
        }
    }

    func infiniteScrollTriggered() {
        guard !paginator.hasLoadedAllPages else {
            debugLog("Triggered infinite scroll when there are no more pages to load.")
            return
        }
        fetchNextPage(firstPage: false,
                      transitioningState: .loadingMore)
    }

    func pullToRefreshTriggered() {
        datasourceManagedView.hideNeedsLoadingIndicator()
        fetchNextPage(firstPage: true, transitioningState: .refreshing)
    }

    func fetchNextPage(firstPage: Bool = false,
                       transitioningState: State? = .loading,
                       reloadCompletion: VoidClosure? = nil) {
        if let state = transitioningState {
            transition(to: state)
        }

        if firstPage { paginator.reset(stashingLastPageInfo: true) }
        paginator.fetchNextPage(success: { [weak self] items, isLastPage in
            self?.didFinishFetching(result: (items, isLastPage), isFirstPage: firstPage, reloadCompletion: reloadCompletion)
        }, failure: { [weak self] error in
            self?.paginator.restoreLastPageInfo()
            self?.didFinishFetching(error: error)
            reloadCompletion?()
        })
    }

    func didFinishFetching(result: PaginationResult<ItemIdentifierType>,
                           isFirstPage: Bool = false,
                           reloadCompletion: VoidClosure? = nil) {
        let completion = { [weak self] in
            guard let self = self else { return }
            let lastPageState: State = result.items.count > 0 ? .loadedAll : .empty
            self.transition(to: result.isLastPage ? lastPageState : .loaded, animated: true, completion: reloadCompletion)
        }

        if isFirstPage {
            datasource.load(result.items, completion: {
                DispatchQueue.main.async {
                    completion()
                }
            })
        } else {
            datasourceManagedView.setContentOffset(datasourceManagedView.contentOffset, animated: false)
            datasource.append(result.items, completion: {
                DispatchQueue.main.async {
                    completion()
                }
            })
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
                self.datasourceManagedView.loadingControls.pullToRefresh.end()
            }

            switch state {
            case .initialized:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = false
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = false

            case .loading:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = false
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = false

            case .loadedAll:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = true

            case .loaded:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.datasourceManagedView.isScrollEnabled = true

            case .loadingMore:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = true

            case .refreshing:
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = true

            case .refreshingError:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.datasourceManagedView.isScrollEnabled = true
            case .empty:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = false
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = false
            case .error:
                self.datasourceManagedView.loadingControls.pullToRefresh.isEnabled = false
                self.datasourceManagedView.loadingControls.infiniteScroll.isEnabled = false
                self.datasourceManagedView.isScrollEnabled = false
            default:
                break
            }

            if state != .loadingMore {
                self.datasourceManagedView.loadingControls.infiniteScroll.end()
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
                datasourceManagedView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            datasourceManagedView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 275.0, right: 0.0)
            addInfinityScroll()

            datasourceManagedView.bounces = true
            datasourceManagedView.loadingControls.infiniteScroll.isStickToContent = true
        }
    }

    func addPullToRefresh() {
        datasourceManagedView.loadingControls.pullToRefresh.add(direction: paginationConfig.scrollDirection,
                                                                animator: createPullToRefreshAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.pullToRefreshTriggered()
            }
        }
    }

    func addInfinityScroll() {
        datasourceManagedView.loadingControls.infiniteScroll.add(direction: paginationConfig.scrollDirection,
                                                                 animator: createInfiniteScrollAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.infiniteScrollTriggered()
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
    var datasourceManagedView: UIScrollView {
        return tableView
    }

//    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
//        DispatchQueue.main.async {
//            self.tableView.reloadData { [weak self] in
//                self?.tableView.forceAutolayoutPass()
//                if let state = stateAtCompletion { self?.transition(to: state) }
//                completion?()
//            }
//        }
//    }
}

public extension PaginationManaged where Self: UITableViewController {
    var datasourceManagedView: UIScrollView {
        return tableView
    }

//    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
//        DispatchQueue.main.async {
//            self.tableView.reloadData { [weak self] in
//                self?.tableView.forceAutolayoutPass()
//                if let state = stateAtCompletion { self?.transition(to: state) }
//                completion?()
//            }
//        }
//    }

//    func removeCells(boundTo models: [ItemIdentifierType], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
//        enqueue { [weak self] _ in
//            guard let self = self else { return }
//            let indexPathsToRemove = self.dataSource.removeAndReturnIndexes(models: models)
//            if indexPathsToRemove.count > 0 {
//                self.tableView.beginUpdates()
//                self.tableView.deleteRows(at: indexPathsToRemove, with: rowAnimation)
//                self.tableView.endUpdates()
//            }
//        }
//    }
}

public extension PaginationManaged where Self: UICollectionViewController {
    var datasourceManagedView: UIScrollView {
        return collectionView!
    }

//    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
//        DispatchQueue.main.async {
//            self.collectionView!.reloadData { [weak self] in
//                self?.collectionView!.forceAutolayoutPass()
//                if let state = stateAtCompletion { self?.transition(to: state) }
//                completion?()
//            }
//        }
//    }
}
