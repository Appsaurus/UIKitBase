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
    public let horizontalStackView: UIStackView = UIStackView(layout: .fillProportionatelyHorizontal)
    private let rightStackedViews: [UIView]

    public init(contentView: UISearchBar, contentInsets: UIEdgeInsets = .zero, rightStackedViews: [UIView] = []) {
        self.contentView = contentView
        self.contentInsets = contentInsets
        self.rightStackedViews = rightStackedViews
        super.init(frame: CGRect.zero)
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(horizontalStackView)
        let stackedViews = [contentView] + rightStackedViews
        horizontalStackView.addArrangedSubviews(stackedViews)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        contentView.height.equalToSuperview()
        contentView.width ≥ 1
        contentView.resistCompression()
        rightStackedViews.hugContent()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        horizontalStackView.frame = bounds.inset(by: contentInsets)
    }
}

open class SearchState {
    open var lastSearchQuery: String?
}

open class SearchControls {
    open var searchBar: UISearchBar = UISearchBar()
    open var additionalRightViews: [UIView] = []
    open var additionalLeftViews: [UIView] = []
}

open class SearchResultsControllers {
    open var resultsViewController: SearchResultsViewController
    open var preSearchViewController: UIViewController?

    public init(resultsViewController: SearchResultsViewController,
                preSearchViewController: UIViewController? = nil) {
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
                cachesQueryOnResignation: Bool? = nil) {
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
                displaysNavigationbarSearchControls: Bool = false) {
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

    open override func initialChildViewController() -> UIViewController {
        return resultsController.preSearchViewController ?? resultsController.resultsViewController
    }

    open override func createHeaderView() -> UIView? {
        guard layoutConfig.searchBarPosition == .header else {
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
        switch layoutConfig.searchBarPosition {
        case .header:
            if layoutConfig.displaysNavigationbarSearchControls {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", action: didTapNavigationCancelBar)
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", action: didTapNavigationSearchBar)
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

    open override func viewWillDisappear(_ animated: Bool) {
        searchBarWasActiveWhenLastVisible = searchBar.isFirstResponder
        super.viewWillDisappear(animated)
        if endsEditingOnDisappearance {
            resignSearchBar()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldBecomeFirstResponder = config.searchBarRegainsFirstResponderOnReappear && searchBarWasActiveWhenLastVisible
        restorePreviousSearchState(makeSearchBarFirstResponder: shouldBecomeFirstResponder)
    }

    open func queryInputChanged() {
        guard let searchThrottle = config.searchThrottle else {
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
            self.resultsController.resultsViewController.fetchResults(query: query)
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resignSearch()
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
        let resultsViewController = resultsController.resultsViewController
        swap(out: resultsViewController,
             with: preSearchViewController,
             into: containerView,
             completion: {
                 guard let statefulVC = resultsViewController as? StatefulViewController else { return }
                 statefulVC.transition(to: statefulVC.currentState)
        })
    }

    open func resignSearchBar(forceClearQuery: Bool = false) {
        if config.cachesQueryOnResignation {
            searchState.lastSearchQuery = searchBar.text
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
        searchState.lastSearchQuery = nil
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
             with: resultsViewController,
             into: containerView,
             completion: { [weak self] in
                 guard let self = self else { return }
                 self.restorePreviousSearchState()

        })
    }

    open func restorePreviousSearchState(makeSearchBarFirstResponder: Bool = false) {
        if let query = searchState.lastSearchQuery, self.searchBar.text != query {
            searchBar.text = query
            queryInputChanged()
        }
        if makeSearchBarFirstResponder { searchBar.becomeFirstResponder() }
        searchBar.setShowsCancelButton(searchBar.isFirstResponder, animated: false)
    }
}

extension SearchViewController {
    open var searchBar: UISearchBar {
        return controls.searchBar
    }

    open var searchQuery: String? {
        return searchBar.searchQuery
    }

    open var resultsViewController: SearchResultsViewController {
        return self.resultsController.resultsViewController
    }

    open var preSearchViewController: UIViewController? {
        return resultsController.preSearchViewController
    }
}

private extension UISearchBar {
    var searchQuery: String? {
        return textField?.text.removeEmpty
    }

    var hasSearchQuery: Bool {
        guard let _ = searchQuery else { return false }
        return true
    }
}
