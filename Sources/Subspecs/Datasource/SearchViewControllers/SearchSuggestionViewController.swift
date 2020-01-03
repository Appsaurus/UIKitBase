//
//  SearchSuggestionViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 6/14/19.
//

import DarkMagic
import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

open class ManagedSearchViewController: NSObject {
    open var resultsController: SearchResultsControllers
    open var config = SearchViewControllerConfiguration()
    open var searchState = SearchState()
    open var controls = SearchControls()

    public init(resultsController: SearchResultsControllers) {
        self.resultsController = resultsController
    }

    open var resultsViewController: SearchResultsViewController {
        return resultsController.resultsViewController
    }

    open var preSearchViewController: UIViewController? {
        return resultsController.preSearchViewController
    }

    open var searchBar: UISearchBar {
        return controls.searchBar
    }
}

extension DualSearchViewController: TaskResultDelegate {
    public typealias TaskResult = QueryType
}

open class DualSearchViewController<QueryType>: BaseParentViewController, UISearchBarDelegate {
    open lazy var currentSearchController: ManagedSearchViewController = self.primarySearchViewController
    open lazy var primarySearchViewController: ManagedSearchViewController = self.createPrimarySearchViewController()
    open lazy var secondarySearchViewController: ManagedSearchViewController = self.createSecondarySearchViewController()

    public var result: QueryType?
    public var onDidFinishTask: (result: (QueryType) -> Void, cancelled: VoidClosure)?
    public var previousQuery: String?

    public required init(primarySearchViewController: ManagedSearchViewController? = nil,
                         secondarySearchViewController: ManagedSearchViewController? = nil,
                         existingQuery: QueryType? = nil,
                         onDidFinishTask: TaskCompletionClosure? = nil) {
        result = existingQuery
        super.init(callInitLifecycle: false)
        self.primarySearchViewController =? primarySearchViewController
        self.secondarySearchViewController =? secondarySearchViewController
        self.onDidFinishTask =? onDidFinishTask
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public let searchStackView = StackView()

    open lazy var searchLayoutView: UIView = {
        let layoutView = UIView()
        layoutView.addSubview(searchStackView)
        searchStackView.pinToSuperview()
        searchStackView
            .on(.vertical)
            .stack(primaryControls.additionalLeftViews + [primaryControls.searchBar] + primaryControls.additionalRightViews,
                   secondaryControls.additionalLeftViews + [secondaryControls.searchBar] + secondaryControls.additionalRightViews)
        return layoutView
    }()

    open func createPrimarySearchViewController() -> ManagedSearchViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        // swiftlint:disable:next force_cast
        let resultsVC = SearchResultsControllers(resultsViewController: UIViewController() as! SearchResultsViewController,
                                                 preSearchViewController: UIViewController())
        return ManagedSearchViewController(resultsController: resultsVC)
    }

    open func createSecondarySearchViewController() -> ManagedSearchViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        // swiftlint:disable:next force_cast
        let resultsVC = SearchResultsControllers(resultsViewController: UIViewController() as! SearchResultsViewController,
                                                 preSearchViewController: UIViewController())
        return ManagedSearchViewController(resultsController: resultsVC)
    }

    open func resolveQuery() -> QueryType {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return "" as! QueryType // swiftlint:disable:this force_cast
    }

    open override func initialChildViewController() -> UIViewController {
        return primarySearchViewController.preSearchViewController ?? primarySearchViewController.resultsViewController
    }

    open override func createHeaderView() -> UIView? {
        return searchLayoutView
    }

    open override func style() {
        super.style()
        searchBars.forEach { $0.textField?.subviews.first?.cornerRadius = 10.0 }
    }

    open override func setupDelegates() {
        super.setupDelegates()
        searchBars.forEach { $0.delegate = self }
    }

    open override func createSubviews() {
        super.createSubviews()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", action: didTapNavigationCancelBar)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", action: didTapNavigationSearchBar)
    }

    open func didTapNavigationCancelBar() {
        dismiss(animated: true, completion: onDidFinishTask?.cancelled)
    }

    open func didTapNavigationSearchBar() {
        submitSearch()
    }

    open func submitSearch() {
        finishTask(with: result ?? resolveQuery())
    }

    public func finishTask() {
        guard let result = result else { return }
        onDidFinishTask?.result(result)
    }

    public func cancelTask() {
        onDidFinishTask?.cancelled()
    }

    private var lastActiveSearchBar: UISearchBar?

    private var searchBarWasActiveWhenLastVisible: Bool {
        return lastActiveSearchBar != nil
    }

    open override func viewWillDisappear(_ animated: Bool) {
        lastActiveSearchBar = searchBars.first(where: { $0.isFirstResponder })
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
//            resignSearchBar(resultsController: currentSearchController)
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldBecomeFirstResponder = currentSearchController.config.searchBarRegainsFirstResponderOnReappear && searchBarWasActiveWhenLastVisible
        restorePreviousSearchState(to: currentSearchController, makeSearchBarFirstResponder: shouldBecomeFirstResponder)
    }

    open func queryInputChanged() {
        queryInputChanged(resultsController: currentSearchController)
    }

    open func queryInputChanged(resultsController: ManagedSearchViewController) {
        guard let searchThrottle = resultsController.config.searchThrottle else {
            performSearch(query: resultsController.searchBar.searchQuery, on: resultsController)
            return
        }

        // Throttle network activity
        let performSearchSelector = #selector(DualSearchViewController.triggerSearch(resultsController:))
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: performSearchSelector, object: nil)
        perform(performSearchSelector, with: resultsController, afterDelay: TimeInterval(searchThrottle))
    }

    @objc private func triggerSearch(resultsController: ManagedSearchViewController) {
        performSearch(query: resultsController.searchBar.searchQuery, on: resultsController)
    }

    open func performSearch(query: String?, on resultsController: ManagedSearchViewController) {
        DispatchQueue.main.async {
            resultsController.resultsViewController.fetchResults(query: query)
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resignSearch()
    }

    open func resignSearch(forceClearQuery: Bool? = nil) {
        resignSearch(resultsController: currentSearchController, forceClearQuery: forceClearQuery)
    }

    private func resignSearch(resultsController: ManagedSearchViewController, forceClearQuery: Bool? = nil) {
        DispatchQueue.main.async {
            let clearQuery = forceClearQuery ?? resultsController.config.clearsResultsOnCancel
            self.resignSearchBar(resultsController: resultsController, forceClearQuery: clearQuery)
            self.hideSearchResultsViewController() // If there is a preSearchViewController, swap it back in
        }
    }

    open func hideSearchResultsViewController() {
        guard let preSearchViewController = currentSearchController.preSearchViewController, preSearchViewController != children.first else {
            return
        }

        swap(out: children[0],
             with: preSearchViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 guard let statefulVC = self.currentSearchController.resultsViewController as? StatefulViewController else { return }
                 statefulVC.transition(to: statefulVC.currentState)
        })
    }

    open func resignSearchBar(resultsController: ManagedSearchViewController, forceClearQuery: Bool = false) {
        if resultsController.config.cachesQueryOnResignation {
            resultsController.searchState.lastSearchQuery = resultsController.controls.searchBar.text
        }
        if forceClearQuery {
            clearSearchQuery(resultsController: resultsController)
            queryInputChanged()
        }

        lastActiveSearchBar?.setShowsCancelButton(false, animated: true)
        lastActiveSearchBar?.resignFirstResponder()
    }

    open func resetSearch() {
        resignSearch(forceClearQuery: true)
        lastActiveSearchBar = nil
    }

    open func clearSearchQuery() {
        clearSearchQuery(resultsController: primarySearchViewController)
        clearSearchQuery(resultsController: secondarySearchViewController)
    }

    open func clearSearchQuery(resultsController: ManagedSearchViewController) {
        resultsController.controls.searchBar.text = nil
        resultsController.searchState.lastSearchQuery = nil
    }

    open func resignSearchBarIfActive(forceClearQuery: Bool = false) {
        if currentSearchController.controls.searchBar.isFirstResponder {
            resignSearchBar(resultsController: currentSearchController, forceClearQuery: forceClearQuery)
        }
    }

    public var previousPrimaryQuery: String?
    public var previousSecondaryQuery: String?

    // MARK: UISearchBar Delegate

    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    open func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {}

//    open func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        return true
//    }

    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let resultsController = searchResultsController(for: searchBar)

        let isEmpty = !searchBar.hasSearchQuery
        var wasManuallyClearedByDeleteKeystroke = false
        if searchBar === primarySearchBar {
            wasManuallyClearedByDeleteKeystroke = previousPrimaryQuery?.count == 1 && !primarySearchBar.hasSearchQuery
            previousPrimaryQuery = searchText
        }
        if searchBar === secondarySearchBar {
            wasManuallyClearedByDeleteKeystroke = previousSecondaryQuery?.count == 1 && !secondarySearchBar.hasSearchQuery
            previousSecondaryQuery = searchText
        }
        queryInputChanged(resultsController: resultsController)

        print("isEmpty: \(isEmpty)")
        print("wasManuallyClearedByDeleteKeystroke: \(wasManuallyClearedByDeleteKeystroke)")
        if isEmpty, !wasManuallyClearedByDeleteKeystroke {
            searchBarDidClear(searchBar)
        }
    }

    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let resultsController = searchResultsController(for: searchBar)
        queryInputChanged(resultsController: resultsController)
        searchBar.resignFirstResponder()
    }

    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        currentSearchController = searchResultsController(for: searchBar)

        guard let child = children.first else {
            restorePreviousSearchState(to: currentSearchController)
            return
        }

        swap(out: child,
             with: currentSearchController.resultsViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 self.restorePreviousSearchState(to: self.currentSearchController)

        })
    }

    open func searchBarDidClear(_ searchBar: UISearchBar) {
        print("Search bar did clear \(searchBar)")
        currentSearchController = searchResultsController(for: searchBar)
    }

    open func restorePreviousSearchState(to resultsController: ManagedSearchViewController,
                                         makeSearchBarFirstResponder: Bool = false) {
        let searchBar = resultsController.controls.searchBar
        if let query = resultsController.searchState.lastSearchQuery, searchBar.text != query {
            searchBar.text = query
            queryInputChanged(resultsController: resultsController)
        }
        if makeSearchBarFirstResponder { searchBar.becomeFirstResponder() }
    }
}

extension DualSearchViewController {
    open var secondaryControls: SearchControls {
        return secondarySearchViewController.controls
    }

    open var primaryControls: SearchControls {
        return primarySearchViewController.controls
    }

    open var secondarySearchBar: UISearchBar {
        return secondaryControls.searchBar
    }

    open var primarySearchBar: UISearchBar {
        return primaryControls.searchBar
    }

    open var searchBars: [UISearchBar] {
        return [primarySearchBar, secondarySearchBar]
    }

    open var primaryResultsControllers: SearchResultsControllers {
        return primarySearchViewController.resultsController
    }

    open var secondaryResultsControllers: SearchResultsControllers {
        return secondarySearchViewController.resultsController
    }

    private func searchResultsController(for searchBar: UISearchBar) -> ManagedSearchViewController {
        switch searchBar {
        case primarySearchBar:
            return primarySearchViewController
        case secondarySearchBar:
            return secondarySearchViewController
        default:
            assertionFailure("Unknown searchbar delegated to SearchViewController: \(self)")
            return primarySearchViewController
        }
    }
}

public extension UISearchBar {
    var searchQuery: String? {
        return textField?.text.removeEmpty
    }

    var hasSearchQuery: Bool {
        return searchQuery != nil
    }
}
