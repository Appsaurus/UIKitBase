//
//  SearchViewController.swift
//  Pods
//
//  Created by Brian Strobach on 3/13/17.
//
//

import DarkMagic
import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

class SearchBarContainerView: UIView {
    let contentView: UIView
    let contentInsets: UIEdgeInsets

    init(contentView: UIView, contentInsets: UIEdgeInsets = .zero) {
        self.contentView = contentView
        self.contentInsets = contentInsets
        super.init(frame: CGRect.zero)
        addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds.inset(by: contentInsets)
    }
}

public enum SearchBarPosition {
    case navigationTitle, header
}

// public enum SearchBarAppearanceResponderBehavior{
//    case alwaysRegainFirstResponder
//    case regainFirstResponderIfQueryPresent
//    case neverRegainFirstResponder
// }

public enum SearchDataSource {
    case remote, local
}

open class SearchResultsDisplayingConfiguration {
    var loadsSearchResultsImmediately: Bool = true
    var fetchesResultsWithEmptyQuery: Bool = true
    var searchDataSourceType: SearchDataSource = .remote
}

public protocol SearchResultsDisplaying {
    var loadsSearchResultsImmediately: Bool { get set }
    var searchDataSourceType: SearchDataSource { get set }
    func fetchResults(query: String?)
}

private extension AssociatedObjectKeys {
    static let searchConfiguration = AssociatedObjectKey<SearchResultsDisplayingConfiguration>("searchConfiguration")
}

public extension SearchResultsDisplaying where Self: NSObject {
    var searchConfiguration: SearchResultsDisplayingConfiguration {
        get {
            return self[.searchConfiguration, SearchResultsDisplayingConfiguration()]
        }
        set {
            self[.searchConfiguration] = newValue
        }
    }

    var fetchesResultsWithEmptyQuery: Bool {
        get {
            return searchConfiguration.fetchesResultsWithEmptyQuery
        }
        set {
            searchConfiguration.fetchesResultsWithEmptyQuery = newValue
        }
    }

    var loadsSearchResultsImmediately: Bool {
        get {
            return searchConfiguration.loadsSearchResultsImmediately
        }
        set {
            searchConfiguration.loadsSearchResultsImmediately = newValue
        }
    }

    var searchDataSourceType: SearchDataSource {
        get {
            return searchConfiguration.searchDataSourceType
        }
        set {
            searchConfiguration.searchDataSourceType = newValue
        }
    }
}

public typealias SearchResultsViewController = UIViewController & SearchResultsDisplaying

public extension SearchResultsDisplaying where Self: UIViewController & PaginationManaging {
    func fetchResults(query: String?) {
        guard let query = query else {
            switch searchDataSourceType {
            case .remote:
                if fetchesResultsWithEmptyQuery {
                    paginators.activePaginator.searchQuery = nil
                    fetchNextPage(firstPage: true)
                }
            case .local:
                dataSource.removeFilter()
                reloadPaginatableCollectionView(completion: {})
            }
            return
        }
        switch searchDataSourceType {
        case .remote:
            reset(to: .loading)
            paginators.activePaginator.searchQuery = query
            fetchNextPage(firstPage: true)
        case .local:
            dataSource.filterData(searchQuery: query)
            reloadPaginatableCollectionView(completion: {})
        }
    }
}

open class SearchViewController: BaseParentViewController, UISearchBarDelegate {
    open lazy var preSearchViewController: UIViewController? = nil
    open lazy var searchResultsTableViewController: SearchResultsViewController = self.createSearchResultsTableViewController()

    open lazy var searchBar: UISearchBar = UISearchBar()
    open lazy var searchHeaderToolBar: UIToolbar = UIToolbar()
    open lazy var searchLayoutView: UIView = {
        let searchLayoutView = UIView()
        let searchViews: [UIView] = [searchBar, searchHeaderToolBar]
        searchLayoutView.addSubviews(searchViews)
        searchViews.stack(.leadingToTrailing, in: searchLayoutView)
        return searchLayoutView
    }()

    // MARK: SearchBar layout configuration //TODO: Refactor this into single layout config class

    open lazy var searchBarPosition: SearchBarPosition = .header
    open lazy var searchBarInsets: UIEdgeInsets = .zero // This can mess with corner radius of search bar's text field, may need to tweak accordingly

    // MARK: SearchBar layout configuration //TODO: Refactor this into single search config class

    open lazy var searchThrottle: Float? = 0.25
    open lazy var clearsResultsOnCancel: Bool = true
    open lazy var restoreSearchStateOnAppearance: Bool = true
    open lazy var searchBarRegainsFirstResponderOnReappear: Bool = true
    open lazy var cachesQueryOnResignation: Bool = false
    open var lastSearchQuery: String?

    open var userHasEnteredSearchQuery: Bool {
        return searchQuery != nil
    }

    open var searchQuery: String? {
        return searchBar.textField?.text.removeEmpty
    }

    open func createSearchResultsTableViewController() -> SearchResultsViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        // swiftlint:disable:next force_cast
        return UIViewController() as! SearchResultsViewController
    }

    open override func initialChildViewController() -> UIViewController {
        return preSearchViewController ?? searchResultsTableViewController
    }

    open override func createHeaderView() -> UIView? {
        guard searchBarPosition == .header else {
            return nil
        }
        return searchLayoutView
    }

    open override func style() {
        super.style()
        searchBar.textField?.subviews.first?.cornerRadius = 10.0
    }

    open override func setupDelegates() {
        super.setupDelegates()
        searchBar.delegate = self
    }

    open override func createSubviews() {
        super.createSubviews()
        switch searchBarPosition {
        case .navigationTitle:
            let searchBarContainer = SearchBarContainerView(contentView: searchBar, contentInsets: searchBarInsets)
            searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = searchBarContainer

        default: break
        }
    }

    private var searchBarWasActiveWhenLastVisible: Bool = false

    open override func viewWillDisappear(_ animated: Bool) {
        searchBarWasActiveWhenLastVisible = searchBar.isFirstResponder
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
            resignSearchBar()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldBecomeFirstResponder = searchBarRegainsFirstResponderOnReappear && searchBarWasActiveWhenLastVisible
        restorePreviousSearchState(makeSearchBarFirstResponder: shouldBecomeFirstResponder)
    }

    open func queryInputChanged() {
        guard let searchThrottle = searchThrottle else {
            performSearch(query: searchQuery)
            return
        }

        // Throttle network activity
        let performSearchSelector = #selector(SearchViewController.triggerSearch)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: performSearchSelector, object: nil)
        perform(performSearchSelector, with: nil, afterDelay: TimeInterval(searchThrottle))
    }

    @objc private func triggerSearch() {
        performSearch(query: searchQuery)
    }

    open func performSearch(query: String?) {
        DispatchQueue.main.async {
            self.searchResultsTableViewController.fetchResults(query: query)
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resignSearch()
    }

    open func resignSearch(forceClearQuery: Bool? = nil) {
        DispatchQueue.main.async {
            let clearQuery = forceClearQuery ?? self.clearsResultsOnCancel
            self.resignSearchBar(forceClearQuery: clearQuery)
            self.hideSearchResultsViewController() // If there is a preSearchViewController, swap it back in
        }
    }

    open func hideSearchResultsViewController() {
        guard let preSearchViewController = preSearchViewController, preSearchViewController != children.first else {
            return
        }

        swap(out: searchResultsTableViewController,
             with: preSearchViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 guard let statefulVC = self.searchResultsTableViewController as? StatefulViewController else { return }
                 statefulVC.transition(to: statefulVC.currentState)
        })
    }

    open func resignSearchBar(forceClearQuery: Bool = false) {
        if cachesQueryOnResignation {
            lastSearchQuery = searchBar.text
        }
        if forceClearQuery {
            clearSearchQuery()
            queryInputChanged()
        }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    open func resetSearch() {
        resignSearch(forceClearQuery: true)
        searchBarWasActiveWhenLastVisible = false
    }

    open func clearSearchQuery() {
        lastSearchQuery = nil
        searchBar.text = nil
    }

    open func resignSearchBarIfActive(forceClearQuery: Bool = false) {
        if searchBar.isFirstResponder {
            resignSearchBar(forceClearQuery: forceClearQuery)
        }
    }

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        queryInputChanged()
    }

    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        queryInputChanged()
        searchBar.resignFirstResponder()
    }

    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let preSearchViewController = preSearchViewController, preSearchViewController == children.first else {
            restorePreviousSearchState()
            return
        }

        swap(out: preSearchViewController,
             with: searchResultsTableViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 self.restorePreviousSearchState()

        })
    }

    open func restorePreviousSearchState(makeSearchBarFirstResponder: Bool = false) {
        if let query = self.lastSearchQuery, self.searchBar.text != query {
            searchBar.text = query
            queryInputChanged()
        }
        if makeSearchBarFirstResponder { searchBar.becomeFirstResponder() }
        searchBar.setShowsCancelButton(searchBar.isFirstResponder, animated: false)
    }
}
