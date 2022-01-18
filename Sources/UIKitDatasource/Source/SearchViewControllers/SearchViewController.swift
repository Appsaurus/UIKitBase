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

open class SearchBarContainerView: BaseView {
    public let contentView: UISearchBar
    public let contentInsets: UIEdgeInsets
    public let horizontalStackView = UIStackView(layout: .fillProportionatelyHorizontal)
    private let rightStackedViews: [UIView]

    public init(contentView: UISearchBar, contentInsets: UIEdgeInsets = .zero, rightStackedViews: [UIView] = []) {
        self.contentView = contentView
        self.contentInsets = contentInsets
        self.rightStackedViews = rightStackedViews
        super.init(frame: CGRect.zero)
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.horizontalStackView)
        let stackedViews = [contentView] + self.rightStackedViews
        self.horizontalStackView.addArrangedSubviews(stackedViews)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.contentView.height.equalToSuperview()
        self.contentView.width ≥ 1
        self.contentView.resistCompression()
        self.rightStackedViews.hugContent()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.horizontalStackView.frame = bounds.inset(by: self.contentInsets)
    }
}

open class SearchState {
    open var lastSearchQuery: String?
}

open class SearchControls {
    open var searchBar = UISearchBar()
    open var additionalRightViews: [UIView] = []
    open var additionalLeftViews: [UIView] = []
}

open class SearchResultsControllers {
    open var resultsViewController: SearchResultsViewController
    open var preSearchViewController: UIViewController?

    public init(resultsViewController: SearchResultsViewController,
                preSearchViewController: UIViewController? = nil)
    {
        self.resultsViewController = resultsViewController
        self.preSearchViewController = preSearchViewController
    }
}

public enum SearchBarPosition {
    case navigationTitle, header
}

open class SearchViewControllerConfiguration {
    open var searchThrottle: Float?
    open var clearsResultsOnCancel: Bool = true
    open var restoreSearchStateOnAppearance: Bool = true
    open var searchBarRegainsFirstResponderOnReappear: Bool = true
    open var cachesQueryOnResignation: Bool = false

    public init(searchThrottle: Float? = 0.25,
                clearsResultsOnCancel: Bool? = nil,
                restoreSearchStateOnAppearance: Bool? = nil,
                searchBarRegainsFirstResponderOnReappear: Bool? = nil,
                cachesQueryOnResignation: Bool? = nil)
    {
        self.searchThrottle = searchThrottle
        self.clearsResultsOnCancel =? clearsResultsOnCancel
        self.restoreSearchStateOnAppearance =? restoreSearchStateOnAppearance
        self.searchBarRegainsFirstResponderOnReappear =? searchBarRegainsFirstResponderOnReappear
        self.cachesQueryOnResignation =? cachesQueryOnResignation
    }
}

open class SearchViewControllerLayoutConfiguration {
    open var searchBarPosition: SearchBarPosition
    open var searchBarInsets: UIEdgeInsets // This can mess with corner radius of search bar's text field, may need to tweak accordingly
    open var displaysNavigationbarSearchControls: Bool

    public init(searchBarPosition: SearchBarPosition = .header,
                searchBarInsets: UIEdgeInsets = .zero,
                displaysNavigationbarSearchControls: Bool = false)
    {
        self.searchBarPosition = searchBarPosition
        self.searchBarInsets = searchBarInsets
        self.displaysNavigationbarSearchControls = displaysNavigationbarSearchControls
    }
}

open class SearchViewController: BaseParentViewController, UISearchBarDelegate {
    open lazy var resultsController: SearchResultsControllers = self.createSearchResultsControllers()

    open var config = SearchViewControllerConfiguration()
    open var layoutConfig = SearchViewControllerLayoutConfiguration()
    open var searchState = SearchState()
    open var controls = SearchControls()

    open lazy var searchLayoutView: StackView = {
        let searchStack = StackView()

        searchStack
            .on(.horizontal)
            .stack([controls.additionalLeftViews + [controls.searchBar] + controls.additionalRightViews])
        return searchStack
    }()

    open func createSearchResultsControllers() -> SearchResultsControllers {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        // swiftlint:disable:next force_cast
        return SearchResultsControllers(resultsViewController: UIViewController() as! SearchResultsViewController,
                                        preSearchViewController: UIViewController())
    }

    override open func initialChildViewController() -> UIViewController {
        return self.resultsController.preSearchViewController ?? self.resultsController.resultsViewController
    }

    override open func createHeaderView() -> UIView? {
        guard self.layoutConfig.searchBarPosition == .header else {
            return nil
        }
        return self.searchLayoutView
    }

    override open func style() {
        super.style()
        self.searchBar.textField?.subviews.first?.cornerRadius = 10.0
    }

    override open func setupDelegates() {
        super.setupDelegates()
        self.searchBar.delegate = self
    }

    override open func createSubviews() {
        super.createSubviews()
        switch self.layoutConfig.searchBarPosition {
        case .header:
            if self.layoutConfig.displaysNavigationbarSearchControls {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", action: self.didTapNavigationCancelBar)
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", action: self.didTapNavigationSearchBar)
            }
        case .navigationTitle:
            let searchBarContainer = SearchBarContainerView(contentView: searchBar, contentInsets: layoutConfig.searchBarInsets)
            searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = searchBarContainer
        }
    }

    open func didTapNavigationCancelBar() {}

    open func didTapNavigationSearchBar() {}

    var searchBarWasActiveWhenLastVisible: Bool = false

    override open func viewWillDisappear(_ animated: Bool) {
        self.searchBarWasActiveWhenLastVisible = self.searchBar.isFirstResponder
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
            self.resignSearchBar()
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldBecomeFirstResponder = self.config.searchBarRegainsFirstResponderOnReappear && self.searchBarWasActiveWhenLastVisible
        self.restorePreviousSearchState(makeSearchBarFirstResponder: shouldBecomeFirstResponder)
    }

    open func queryInputChanged() {
        guard let searchThrottle = config.searchThrottle else {
            self.performSearch(query: searchQuery())
            return
        }

        // Throttle network activity
        let performSearchSelector = #selector(SearchViewController.triggerSearch)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: performSearchSelector, object: nil)
        perform(performSearchSelector, with: nil, afterDelay: TimeInterval(searchThrottle))
    }

    @objc private func triggerSearch() {
        self.performSearch(query: searchQuery())
    }

    open func performSearch(query: String?) {
        DispatchQueue.main.async {
            self.resultsController.resultsViewController.fetchResults(query: query)
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resignSearch()
    }

    open func resignSearch(forceClearQuery: Bool? = nil) {
        DispatchQueue.main.async {
            let clearQuery = forceClearQuery ?? self.config.clearsResultsOnCancel
            self.resignSearchBar(forceClearQuery: clearQuery)
            self.hideSearchResultsViewController() // If there is a preSearchViewController, swap it back in
        }
    }

    open func hideSearchResultsViewController() {
        guard let preSearchViewController = resultsController.preSearchViewController, preSearchViewController != children.first else {
            return
        }
        let resultsViewController = self.resultsController.resultsViewController
        swap(out: resultsViewController,
             with: preSearchViewController,
             into: containerView,
             completion: {
                 guard let statefulVC = resultsViewController as? StatefulViewController else { return }
                 statefulVC.transition(to: statefulVC.currentState)
             })
    }

    open func resignSearchBar(forceClearQuery: Bool = false) {
        if self.config.cachesQueryOnResignation {
            self.searchState.lastSearchQuery = self.searchBar.text
        }
        if forceClearQuery {
            self.clearSearchQuery()
            self.queryInputChanged()
        }
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.resignFirstResponder()
    }

    open func resetSearch() {
        self.resignSearch(forceClearQuery: true)
        self.searchBarWasActiveWhenLastVisible = false
    }

    open func clearSearchQuery() {
        self.searchState.lastSearchQuery = nil
        self.searchBar.text = nil
    }

    open func resignSearchBarIfActive(forceClearQuery: Bool = false) {
        if self.searchBar.isFirstResponder {
            self.resignSearchBar(forceClearQuery: forceClearQuery)
        }
    }

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.queryInputChanged()
    }

    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.queryInputChanged()
        searchBar.resignFirstResponder()
    }

    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let preSearchViewController = preSearchViewController, preSearchViewController == children.first else {
            self.restorePreviousSearchState()
            return
        }

        swap(out: preSearchViewController,
             with: resultsViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 self.restorePreviousSearchState()

             })
    }

    open func restorePreviousSearchState(makeSearchBarFirstResponder: Bool = false) {
        if let query = searchState.lastSearchQuery, self.searchBar.text != query {
            self.searchBar.text = query
            self.queryInputChanged()
        }
        if makeSearchBarFirstResponder { self.searchBar.becomeFirstResponder() }
        self.searchBar.setShowsCancelButton(self.searchBar.isFirstResponder, animated: false)
    }
}

extension SearchViewController {
    open var searchBar: UISearchBar {
        return controls.searchBar
    }

    open func searchQuery(filterEmpty: Bool = true) -> String? {
        return self.searchBar.searchQuery(filterEmpty: filterEmpty)
    }

    open var resultsViewController: SearchResultsViewController {
        return self.resultsController.resultsViewController
    }

    open var preSearchViewController: UIViewController? {
        return self.resultsController.preSearchViewController
    }
}

public protocol SearchBarReferencing {
    var searchBar: UISearchBar { get }
}

extension SearchBarReferencing {}
