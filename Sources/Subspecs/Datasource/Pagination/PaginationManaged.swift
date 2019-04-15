//
//  PaginationManaged.swift
//  Pods
//
//  Created by Brian Strobach on 3/16/17.
//
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme
// import DeepDiff
open class AsyncStateChange {
    func performStateChange(completion: @escaping VoidClosure) {}
}

// public protocol PaginationManaged: StatefulViewController, AsyncDatasourceChangeManager {
//    associatedtype PaginatableModel: Equatable
//
//    var activePaginator: Paginator<PaginatableModel> { get set }
//    var paginator: Paginator<PaginatableModel> { get set }
//    var fallbackPaginator: Paginator<PaginatableModel>? { get set }
//    var dataSource: CollectionDataSource<PaginatableModel> { get set }
//    var infiniteScrollable: Bool { get set }
//    var scrollDirection: InfinityScrollDirection { get }
//    var refreshable: Bool { get set }
//    var paginatableScrollView: UIScrollView { get }
//    var prefetchedData: [PaginatableModel]? { get set }
//    var loadsResultsImmediately: Bool { get set }
//    var appendsIndexPathsOnInfinityScroll: Bool { get set }
//    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator
//    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator
//    func infiniteScrollTriggered()
//    func pullToRefreshTriggered()
//    func setupPaginatable()
//
//    func refreshDidFail(with error: Error)
//    func loadMoreDidFail(with error: Error)
//    func fetchNextPage(firstPage: Bool, transitioningState: State?, reloadCompletion: VoidClosure?)
//    func didFinishFetching(error: Error)
//    func didFinishFetching(result: PaginationResult<PaginatableModel>, isFirstPage: Bool, reloadCompletion: VoidClosure?)
//    func reloadPaginatableCollectionView(stateAtCompletion: State?, completion: VoidClosure?)
//    func reset(to initialState: State, completion: VoidClosure?)
//    func reload()
//    func reloadDidBegin()
// }
//
// public extension PaginationManaged where Self: UIViewController {
//    var scrollDirection: InfinityScrollDirection {
//        return .vertical
//    }
//
//    func reset(to initialState: State = .initialized, completion: VoidClosure? = nil) {
//        DispatchQueue.main.async {
//            self.dataSource.reset()
//            self.paginator.reset()
//            self.fallbackPaginator?.reset()
//            self.activePaginator = self.paginator
//            self.reloadPaginatableCollectionView(stateAtCompletion: initialState, completion: completion)
//        }
//    }
//
//    func reload() {
//        DispatchQueue.main.async {
//            self.enqueue { [weak self] complete in
//                self?.paginatableScrollView.hideNeedsLoadingIndicator()
//                self?.fetchNextPage(firstPage: true, transitioningState: .loading, reloadCompletion: complete)
//                self?.reloadDidBegin()
//            }
//        }
//    }
//
//    func reloadPaginatableCollectionView(completion: @escaping VoidClosure) {
//        reloadPaginatableCollectionView(stateAtCompletion: .loaded, completion: completion)
//    }
//
//    func reloadDidBegin() {}
//
//    func startLoadingData() {
//        if loadsResultsImmediately {
//            if let prefetchedData = prefetchedData {
//                if prefetchedData.count == 0 {
//                    transition(to: .empty)
//                } else {
//                    didFinishFetching(result: (prefetchedData, true), isFirstPage: true)
//                }
//            } else {
//                reload()
//            }
//        }
//        var retryTitle: String?
//        if emptyView()?.responseButton.title(for: .normal).isNilOrEmpty == true {
//            retryTitle = "Reload"
//        }
//        emptyView()?.set(responseButtonTitle: retryTitle, responseAction: reload)
//    }
//
//    func infiniteScrollTriggered() {
//        guard !activePaginator.hasLoadedAllPages else {
//            debugLog("Triggered infinite scroll when there are no more pages to load.")
//            return
//        }
//        enqueue { [weak self] completion in
//            self?.fetchNextPage(firstPage: false, transitioningState: .loadingMore, reloadCompletion: completion)
//        }
//    }
//
//    func pullToRefreshTriggered() {
//        enqueue { [weak self] completion in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.paginatableScrollView.hideNeedsLoadingIndicator()
//            }
//            self.fetchNextPage(firstPage: true, transitioningState: .refreshing, reloadCompletion: completion)
//        }
//    }
//
//    func fetchNextPage(firstPage: Bool = false, transitioningState: State? = .loading, reloadCompletion: VoidClosure? = nil) {
//        if let state = transitioningState {
//            transition(to: state)
//        }
//        let existingNextPage = activePaginator.nextPageToken
//        if firstPage { activePaginator.nextPageToken = nil }
//        activePaginator.fetchNextPage(success: { [weak self] items, isLastPage in
//            DispatchQueue.main.async {
//                self?.didFinishFetching(result: (items, isLastPage), isFirstPage: firstPage, reloadCompletion: reloadCompletion)
//            }
//        }, failure: { [weak self] error in
//            DispatchQueue.main.async {
//                self?.activePaginator.nextPageToken = existingNextPage
//                self?.didFinishFetching(error: error)
//                reloadCompletion?()
//            }
//        })
//    }
//
//    func didFinishFetching(result: PaginationResult<PaginatableModel>, isFirstPage: Bool = false, reloadCompletion: VoidClosure? = nil) {
//        DispatchQueue.main.async {
//            if isFirstPage {
//                if self.dataSource.rawModels.count > 0 {
//                    self.dataSource.reset()
//                }
//                if result.items.count == 0 {
//                    guard let fallbackPaginator = self.fallbackPaginator else {
//                        self.reloadPaginatableCollectionView(stateAtCompletion: .empty, completion: reloadCompletion)
//                        return
//                    }
//                    if self.activePaginator === fallbackPaginator {
//                        self.reloadPaginatableCollectionView(stateAtCompletion: .empty, completion: reloadCompletion)
//                        return
//                    }
//                    self.activePaginator = fallbackPaginator
//                    self.fetchNextPage(firstPage: isFirstPage, transitioningState: self.currentState, reloadCompletion: reloadCompletion)
//                    return
//                }
//            }
//            self.dataSource.add(models: result.items)
//            self.reloadPaginatableCollectionView(stateAtCompletion: result.isLastPage ? .loadedAll : .loaded, completion: reloadCompletion)
//        }
//    }
//
//    func didFinishFetching(error: Error) {
//        if (error as NSError).code == NSURLErrorCancelled {
//            return
//        }
//        guard currentState != .loadingMore else {
//            transition(to: .loadMoreError)
//            loadMoreDidFail(with: error)
//            return
//        }
//
//        switch error {
//        default:
//            guard currentState != .refreshing else {
//                transition(to: .refreshingError)
//                refreshDidFail(with: error)
//                return
//            }
//            errorView()?.set(message: "Error: \(error.localizedDescription)", responseButtonTitle: "Try again", responseAction: { [weak self] in
//                guard let sSelf = self else { return }
//                sSelf.fetchNextPage()
//            })
//            transition(to: .error)
//        }
//    }
//
//    func refreshDidFail(with error: Error) {
//        showError(error: error)
//    }
//
//    func loadMoreDidFail(with error: Error) {
//        showError(error: error)
//    }
//
//    // TODO: Refactor to encapsulate this logic for each state and aviod massive switch
//    // swiftlint:disable:next function_body_length cyclomatic_complexity
//    func updatePaginatableViews(for state: State) {
//        DispatchQueue.main.async {
//            if state != .refreshing {
//                self.paginatableScrollView.loadingControls.pullToRefresh.end()
//            }
//
//            switch state {
//            case .initialized:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = false
//
//            case .loading:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = false
//
//            case .loadedAll:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.refreshable
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = true
//
//            case .loaded:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.refreshable
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = self.infiniteScrollable
//                self.paginatableScrollView.isScrollEnabled = true
//
//            case .loadingMore:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = true
//
//            case .refreshing:
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = true
//
//            case .refreshingError:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = self.refreshable
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = self.infiniteScrollable
//                self.paginatableScrollView.isScrollEnabled = true
//            case .empty:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = false
//            case .error:
//                self.paginatableScrollView.loadingControls.pullToRefresh.isEnabled = false
//                self.paginatableScrollView.loadingControls.infiniteScroll.isEnabled = false
//                self.paginatableScrollView.isScrollEnabled = false
//            default:
//                break
//            }
//
//            if state != .loadingMore {
//                self.paginatableScrollView.loadingControls.infiniteScroll.end()
//            }
//        }
//    }
//
//    func setupPaginatable() {
//        if refreshable {
//            addPullToRefresh()
//        }
//
//        if infiniteScrollable {
//            addInfinityScroll()
//        }
//    }
//
//    func setLoadingTriggers(enabled: Bool) {
//        if refreshable {
//            addPullToRefresh()
//        }
//
//        if infiniteScrollable {
//            if #available(iOS 11.0, *) {
//                paginatableScrollView.contentInsetAdjustmentBehavior = .never
//            } else {
//                automaticallyAdjustsScrollViewInsets = false
//            }
//            paginatableScrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 275.0, right: 0.0)
//            addInfinityScroll()
//
//            paginatableScrollView.bounces = true
//            paginatableScrollView.loadingControls.infiniteScroll.isStickToContent = true
//        }
//    }
//
//    func addPullToRefresh() {
//        paginatableScrollView.loadingControls.pullToRefresh.add(direction: scrollDirection, animator: createPullToRefreshAnimator()) { [weak self] in
//            DispatchQueue.main.async {
//                self?.pullToRefreshTriggered()
//            }
//        }
//    }
//
//    func addInfinityScroll() {
//        paginatableScrollView.loadingControls.infiniteScroll.add(direction: scrollDirection, animator: createInfiniteScrollAnimator()) { [unowned self] in
//            DispatchQueue.main.async {
//                self.infiniteScrollTriggered()
//            }
//        }
//    }
//
//    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator {
//        return DefaultRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//    }
//
//    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator {
//        return CircleInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//    }
// }

//// TODO: Turn this into protocol
// extension UITableViewCell {
//    public func removeFromTableView<M: Paginatable>(model: M, animation: UITableView.RowAnimation = .automatic) {
//        guard let tvc = parentViewController as? PaginatableTableViewController<M> else { return }
//        let indexPathsToRemove = tvc.dataSource.removeAndReturnIndexes(models: [model])
//        if indexPathsToRemove.count > 0 {
//            tvc.tableView.beginUpdates()
//            tvc.tableView.deleteRows(at: indexPathsToRemove, with: animation)
//
//            tvc.tableView.endUpdates()
//        }
//    }
// }
