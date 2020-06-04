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
        return self.controls.searchBar
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
        self.result = existingQuery
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

    override open func initialChildViewController() -> UIViewController {
        return self.primarySearchViewController.preSearchViewController ?? self.primarySearchViewController.resultsViewController
    }

    override open func createHeaderView() -> UIView? {
        return self.searchLayoutView
    }

    override open func style() {
        super.style()
        searchBars.forEach { $0.textField?.subviews.first?.cornerRadius = 10.0 }
    }

    override open func setupDelegates() {
        super.setupDelegates()
        searchBars.forEach { $0.delegate = self }
    }

    override open func createSubviews() {
        super.createSubviews()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", action: self.didTapNavigationCancelBar)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", action: self.didTapNavigationSearchBar)
    }

    open func didTapNavigationCancelBar() {
        dismiss(animated: true, completion: self.onDidFinishTask?.cancelled)
    }

    open func didTapNavigationSearchBar() {
        self.submitSearch()
    }

    open func submitSearch() {
        self.finishTask(with: self.result ?? self.resolveQuery())
    }

    public func finishTask() {
        guard let result = result else { return }
        self.onDidFinishTask?.result(result)
    }

    public func cancelTask() {
        self.onDidFinishTask?.cancelled()
    }

    private var lastActiveSearchBar: UISearchBar?

    private var searchBarWasActiveWhenLastVisible: Bool {
        return lastActiveSearchBar != nil
    }

    override open func viewWillDisappear(_ animated: Bool) {
        self.lastActiveSearchBar = searchBars.first(where: { $0.isFirstResponder })
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
//            resignSearchBar(resultsController: currentSearchController)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldBecomeFirstResponder = self.currentSearchController.config.searchBarRegainsFirstResponderOnReappear && self.searchBarWasActiveWhenLastVisible
        self.restorePreviousSearchState(to: self.currentSearchController, makeSearchBarFirstResponder: shouldBecomeFirstResponder)
    }

    open func queryInputChanged() {
        self.queryInputChanged(resultsController: self.currentSearchController)
    }

    open func queryInputChanged(resultsController: ManagedSearchViewController) {
        guard let searchThrottle = resultsController.config.searchThrottle else {
            self.performSearch(query: resultsController.searchBar.searchQuery, on: resultsController)
            return
        }

        // Throttle network activity
        let performSearchSelector = #selector(DualSearchViewController.triggerSearch(resultsController:))
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: performSearchSelector, object: nil)
        perform(performSearchSelector, with: resultsController, afterDelay: TimeInterval(searchThrottle))
    }

    @objc private func triggerSearch(resultsController: ManagedSearchViewController) {
        self.performSearch(query: resultsController.searchBar.searchQuery, on: resultsController)
    }

    open func performSearch(query: String?, on resultsController: ManagedSearchViewController) {
        DispatchQueue.main.async {
            resultsController.resultsViewController.fetchResults(query: query)
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resignSearch()
    }

    open func resignSearch(forceClearQuery: Bool? = nil) {
        self.resignSearch(resultsController: self.currentSearchController, forceClearQuery: forceClearQuery)
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
            self.clearSearchQuery(resultsController: resultsController)
            self.queryInputChanged()
        }

        self.lastActiveSearchBar?.setShowsCancelButton(false, animated: true)
        self.lastActiveSearchBar?.resignFirstResponder()
    }

    open func resetSearch() {
        self.resignSearch(forceClearQuery: true)
        self.lastActiveSearchBar = nil
    }

    open func clearSearchQuery() {
        self.clearSearchQuery(resultsController: self.primarySearchViewController)
        self.clearSearchQuery(resultsController: self.secondarySearchViewController)
    }

    open func clearSearchQuery(resultsController: ManagedSearchViewController) {
        resultsController.controls.searchBar.text = nil
        resultsController.searchState.lastSearchQuery = nil
    }

    open func resignSearchBarIfActive(forceClearQuery: Bool = false) {
        if self.currentSearchController.controls.searchBar.isFirstResponder {
            self.resignSearchBar(resultsController: self.currentSearchController, forceClearQuery: forceClearQuery)
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
            wasManuallyClearedByDeleteKeystroke = self.previousPrimaryQuery?.count == 1 && !primarySearchBar.hasSearchQuery
            self.previousPrimaryQuery = searchText
        }
        if searchBar === secondarySearchBar {
            wasManuallyClearedByDeleteKeystroke = self.previousSecondaryQuery?.count == 1 && !secondarySearchBar.hasSearchQuery
            self.previousSecondaryQuery = searchText
        }
        self.queryInputChanged(resultsController: resultsController)

        print("isEmpty: \(isEmpty)")
        print("wasManuallyClearedByDeleteKeystroke: \(wasManuallyClearedByDeleteKeystroke)")
        if isEmpty, !wasManuallyClearedByDeleteKeystroke {
            self.searchBarDidClear(searchBar)
        }
    }

    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let resultsController = searchResultsController(for: searchBar)
        queryInputChanged(resultsController: resultsController)
        searchBar.resignFirstResponder()
    }

    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.currentSearchController = searchResultsController(for: searchBar)

        guard let child = children.first else {
            self.restorePreviousSearchState(to: self.currentSearchController)
            return
        }

        swap(out: child,
             with: self.currentSearchController.resultsViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 self.restorePreviousSearchState(to: self.currentSearchController)

        })
    }

    open func searchBarDidClear(_ searchBar: UISearchBar) {
        print("Search bar did clear \(searchBar)")
        self.currentSearchController = searchResultsController(for: searchBar)
    }

    open func restorePreviousSearchState(to resultsController: ManagedSearchViewController,
                                         makeSearchBarFirstResponder: Bool = false) {
        let searchBar = resultsController.controls.searchBar
        if let query = resultsController.searchState.lastSearchQuery, searchBar.text != query {
            searchBar.text = query
            self.queryInputChanged(resultsController: resultsController)
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
        return self.secondarySearchViewController.resultsController
    }

    private func searchResultsController(for searchBar: UISearchBar) -> ManagedSearchViewController {
        switch searchBar {
        case self.primarySearchBar:
            return self.primarySearchViewController
        case self.secondarySearchBar:
            return self.secondarySearchViewController
        default:
            assertionFailure("Unknown searchbar delegated to SearchViewController: \(self)")
            return self.primarySearchViewController
        }
    }
}

public extension UISearchBar {
    var searchQuery: String? {
        return textField?.text.removeEmpty
    }

    var hasSearchQuery: Bool {
        return self.searchQuery != nil
    }
}
