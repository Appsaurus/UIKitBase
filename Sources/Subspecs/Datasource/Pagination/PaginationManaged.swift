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
    var paginatingView: UIScrollView { get }
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
    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure?)
    func reset(to initialState: State, completion: VoidClosure?)
    func reload()
    func didReload()
    func reloadDidBegin()
}

public extension PaginationManaged {
    var paginationConfig: PaginationConfiguration {
        return PaginationConfiguration()
    }
}

public extension PaginationManaged where Self: UIViewController {
    func reset(to initialState: State = .initialized, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
//            self.paginationManager.reset()
            self.reloadPaginatingView(stateAtCompletion: initialState, completion: completion)
        }
    }

    func reload() {
        paginatingView.hideNeedsLoadingIndicator()
        reloadDidBegin()
        fetchNextPage(firstPage: true, reloadCompletion: didReload)
    }

    func reloadPaginatableCollectionView(completion: @escaping VoidClosure) {
        reloadPaginatingView(stateAtCompletion: .loaded, completion: completion)
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
        paginatingView.hideNeedsLoadingIndicator()
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
        datasource.add(models: result.items)
        DispatchQueue.main.async {
            self.transition(to: result.isLastPage ? .loadedAll : .loaded, animated: true)
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
                self.paginatingView.loadingControls.pullToRefresh.end()
            }

            switch state {
            case .initialized:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = false

            case .loading:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = false

            case .loadedAll:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = true

            case .loaded:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.paginatingView.isScrollEnabled = true

            case .loadingMore:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatingView.isScrollEnabled = true

            case .refreshing:
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = true

            case .refreshingError:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = self.paginationConfig.refreshable
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = self.paginationConfig.infiniteScrollable
                self.paginatingView.isScrollEnabled = true
            case .empty:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = false
            case .error:
                self.paginatingView.loadingControls.pullToRefresh.isEnabled = false
                self.paginatingView.loadingControls.infiniteScroll.isEnabled = false
                self.paginatingView.isScrollEnabled = false
            default:
                break
            }

            if state != .loadingMore {
                self.paginatingView.loadingControls.infiniteScroll.end()
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
                paginatingView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            paginatingView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 275.0, right: 0.0)
            addInfinityScroll()

            paginatingView.bounces = true
            paginatingView.loadingControls.infiniteScroll.isStickToContent = true
        }
    }

    func addPullToRefresh() {
        paginatingView.loadingControls.pullToRefresh.add(direction: paginationConfig.scrollDirection,
                                                                  animator: createPullToRefreshAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.pullToRefreshTriggered()
            }
        }
    }

    func addInfinityScroll() {
        paginatingView.loadingControls.infiniteScroll.add(direction: paginationConfig.scrollDirection,
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
    var paginatingView: UIScrollView {
        return tableView
    }

    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
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
    var paginatingView: UIScrollView {
        return tableView
    }

    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.tableView.reloadData { [weak self] in
                self?.tableView.forceAutolayoutPass()
                if let state = stateAtCompletion { self?.transition(to: state) }
                completion?()
            }
        }
    }

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
    var paginatingView: UIScrollView {
        return collectionView!
    }

    func reloadPaginatingView(stateAtCompletion: State?, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.collectionView!.reloadData { [weak self] in
                self?.collectionView!.forceAutolayoutPass()
                if let state = stateAtCompletion { self?.transition(to: state) }
                completion?()
            }
        }
    }
}
