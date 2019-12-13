//
//  PaginationManaged.swift
//  Pods
//
//  Created by Brian Strobach on 3/16/17.
//
//

import Actions
import DarkMagic
import DiffableDataSources
import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

public typealias PaginatableTableViewController = BaseTableViewController & PaginationManaged & Refreshable
public typealias PaginatableCollectionViewController = BaseCollectionViewController & PaginationManaged & Refreshable

public typealias PaginatableContainedTableViewController = BaseContainedTableViewController & PaginationManaged & Refreshable
public typealias PaginatableContainedCollectionViewController = BaseContainedCollectionViewController & PaginationManaged & Refreshable

public protocol PaginationManaged: StatefulViewController, DatasourceManaged, InfiniteScrollable, PullToRefreshable, ScrollViewReferencing {
    typealias ItemIdentifierType = Datasource.ItemIdentifierType
    typealias SectionIdentifierType = Datasource.SectionIdentifierType

    var paginator: Paginator<ItemIdentifierType> { get set }
    var paginationConfig: PaginationConfiguration { get }
    func infiniteScrollTriggered()
    func pullToRefreshTriggered()
    func setupPaginatable()

    func refreshDidFail(with error: Error)
    func loadMoreDidFail(with error: Error)
    func fetchNextPage(firstPage: Bool, transitioningState: State?, reloadCompletion: VoidClosure?)
    func didFinishFetching(error: Error)
    func didFinishFetching(result: PaginationResult<ItemIdentifierType>, isFirstPage: Bool, reloadCompletion: VoidClosure?)
    func state(afterFetching result: PaginationResult<ItemIdentifierType>) -> State
    func modifyFetched(result: PaginationResult<ItemIdentifierType>) -> PaginationResult<ItemIdentifierType>
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
        let result = modifyFetched(result: result)

        let completion = { [weak self] in
            guard let self = self else { return }
            self.transition(to: self.state(afterFetching: result), animated: true, completion: reloadCompletion)
        }

        if isFirstPage {
            datasource.load(result.items, animated: true, completion: completion)            
        } else {
            //Turning off animation for now, causing conflicts with ScrollView headers at the moment
            datasource.append(result.items, animated: paginationConfig.animatesDatasourceChanges, completion: completion)
        }
    }

    func state(afterFetching result: PaginationResult<ItemIdentifierType>) -> State {
        let lastPageState: State = result.items.count > 0 ? .loadedAll : .empty
        return result.isLastPage ? lastPageState : .loaded
    }

    func modifyFetched(result: PaginationResult<ItemIdentifierType>) -> PaginationResult<ItemIdentifierType> {
        return result
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
//                self.datasourceManagedView.refreshControl?.endRefreshing()
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
            datasourceManagedView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 275.0, right: 0.0)
            addInfinityScroll()

            datasourceManagedView.bounces = true
            datasourceManagedView.loadingControls.infiniteScroll.isStickToContent = true
        }
    }
}


public protocol PullToRefreshable: class, ScrollViewReferencing, Refreshable {
    func addPullToRefresh(direction: ScrollDirection, animator: CustomPullToRefreshAnimator?)
    func pullToRefreshTriggered()
    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator
}

extension PullToRefreshable where Self: StatefulViewController {
        func updatePullToRefreshableViews(for state: State) {
            var loadingControls = scrollView.loadingControls

                if state != .refreshing {
                    loadingControls.pullToRefresh.end()
                }

                switch state {
                case .initialized, .loading, .empty, .error:
                    loadingControls.pullToRefresh.isEnabled = false
                    scrollView.isScrollEnabled = false
                case .loadedAll, .loaded, .refreshingError:
                    loadingControls.pullToRefresh.isEnabled = true
                    scrollView.isScrollEnabled = true
                case .loadingMore:
                    loadingControls.pullToRefresh.isEnabled = false
                case .refreshing:
                    scrollView.isScrollEnabled = true
                default:
                    break
                }
        }
}
//MARK: - Refreshable
public extension PullToRefreshable{
    func refresh() {
        scrollView.beginRefreshing()
    }
}


public extension PullToRefreshable{
    func addPullToRefresh(direction: ScrollDirection = .vertical, animator: CustomPullToRefreshAnimator? = nil) {
        scrollView.loadingControls.pullToRefresh.add(direction: direction, animator: animator ?? createPullToRefreshAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.pullToRefreshTriggered()
            }
        }
    }

    func createPullToRefreshAnimator() -> CustomPullToRefreshAnimator {
        return ScrollViewLoadingControl.defaultPullToRefreshAnimator()
    }
}

public protocol InfiniteScrollable: class, ScrollViewReferencing {
    func addInfinityScroll(direction: ScrollDirection, animator: CustomInfiniteScrollAnimator?)
    func infiniteScrollTriggered()
    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator
}

public extension InfiniteScrollable {
    func addInfinityScroll(direction: ScrollDirection = .vertical, animator: CustomInfiniteScrollAnimator? = nil) {
        scrollView.loadingControls.infiniteScroll.add(direction: direction, animator: animator ?? createInfiniteScrollAnimator()) { [weak self] in
            DispatchQueue.main.async {
                self?.infiniteScrollTriggered()
            }
        }
    }

    func createInfiniteScrollAnimator() -> CustomInfiniteScrollAnimator {
        return ScrollViewLoadingControl.defaultInfiniteScrollAnimator()
    }
}

open class PullToRefreshableMixin<VC: UIViewController & PullToRefreshable & StatefulViewController>: UIViewControllerMixin<VC> {
    open override func viewDidLoad() {
        super.viewDidLoad()
        mixable.onDidTransitionMixins.append { [weak mixable] state in
            guard let mixable = mixable else { return }
            mixable.updatePullToRefreshableViews(for: state)
        }
    }

    open override func willDeinit() {
        super.willDeinit()
        mixable.scrollView.loadingControls.clear()
    }

    open override func createSubviews() {
        super.createSubviews()
        mixable.addPullToRefresh()
        mixable.scrollView.loadingControls.pullToRefresh.isEnabled = true
    }
}
