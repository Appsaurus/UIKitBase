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

public protocol DualSearchViewControllerDelegate: class {
    func didCancelSearch()
    func userDidSubmitSearch(from dualSearchViewController: DualSearchViewController)
}

open class DualSearchViewController: BaseParentViewController, UISearchBarDelegate {

    open lazy var currentSearchController: ManagedSearchViewController = self.primarySearchViewController
    open lazy var primarySearchViewController: ManagedSearchViewController = self.createPrimarySearchViewController()
    open lazy var secondarySearchViewController: ManagedSearchViewController = self.createSecondarySearchViewController()
    public weak var delegate: DualSearchViewControllerDelegate?

    public required init(primarySearchViewController: ManagedSearchViewController? = nil,
                         secondarySearchViewController: ManagedSearchViewController? = nil,
                         delegate: DualSearchViewControllerDelegate? = nil) {
        super.init(callDidInit: false)
        self.primarySearchViewController =? primarySearchViewController
        self.secondarySearchViewController =? secondarySearchViewController
        self.delegate =? delegate
        didInit(type: .programmatically)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    open lazy var searchLayoutView: UIView = {
        let searchStackView = StackView()
        searchStackView
            .on(.vertical)
            .stack([[primaryControls.searchBar, primaryControls.toolbar],
                    [secondaryControls.searchBar, secondaryControls.toolbar]])
        return searchStackView
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

    open override func initialChildViewController() -> UIViewController {

        return primarySearchViewController.preSearchViewController ?? primarySearchViewController.resultsViewController
    }

    open override func createHeaderView() -> UIView? {
        return searchLayoutView
    }

    open override func style() {
        super.style()
        searchBars.forEach{$0.textField?.subviews.first?.cornerRadius = 10.0 }
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
        dismiss(animated: true, completion: self.delegate?.didCancelSearch)
    }

    open func didTapNavigationSearchBar() {
        submitSearch()
    }

    open func submitSearch() {
        delegate?.userDidSubmitSearch(from: self)
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
            performSearch(query: resultsController.searchBar.searchQuery, on : resultsController)
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

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let resultsController = searchResultsController(for: searchBar)
        queryInputChanged(resultsController: resultsController)
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

    open var secondaryToolbar: UIToolbar {
        return secondaryControls.toolbar
    }
    open var primaryToolbar: UIToolbar {
        return primaryControls.toolbar
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
        case self.primarySearchBar:
            return primarySearchViewController
        case secondarySearchBar:
            return secondarySearchViewController
        default:
            assertionFailure("Unknown searchbar delegated to SearchViewController: \(self)")
            return primarySearchViewController
        }
    }
}

fileprivate extension UISearchBar {
    var searchQuery: String? {
        return textField?.text.removeEmpty
    }
    var hasSearchQuery: Bool {
        guard let searchQuery = searchQuery else { return false }
        return true
    }
}


//open class SearchViewControllerCoordinator: BaseParentViewController {
//
//    open lazy var primarySearchViewController: SearchViewController
//    open lazy var secondarySearchViewController: SearchViewController
//
//
//}

//
//open class SearchViewControllerCoordinator: BaseParentViewController {
//
//    open lazy var primarySearchViewController: SearchViewController
//    open lazy var secondarySearchViewController: SearchViewController
//
//
//    // MARK: SearchBar layout configuration //TODO: Refactor this into single layout config class
//
//    open lazy var searchBarPosition: SearchBarPosition = .header
//    open lazy var searchBarInsets: UIEdgeInsets = .zero // This can mess with corner radius of search bar's text field, may need to tweak accordingly
//
//    open var delegatesFinalSearchInput: Bool = false
//
//
//    open var showsSecondarySearchBar: Bool = false {
//        didSet{
//            if showsSecondarySearchBar { searchBarPosition = .header }
//        }
//    }
//
//    open func createSearchResultsController() -> SearchResultController {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        // swiftlint:disable:next force_cast
//        return SearchResultController(resultsViewController: UIViewController() as! SearchResultsViewController,
//                                      preSearchViewController: UIViewController())
//    }
//
//    open func createSecondarySearchResultsController() -> SearchResultController {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        // swiftlint:disable:next force_cast
//        return SearchResultController(resultsViewController: UIViewController() as! SearchResultsViewController,
//                                      preSearchViewController: UIViewController())
//    }
//
//    open override func initialChildViewController() -> UIViewController {
//        return searchResultsController.preSearchViewController ?? searchResultsController.resultsViewController
//    }
//
//    open override func createHeaderView() -> UIView? {
//        guard searchBarPosition == .header else {
//            return nil
//        }
//        return searchLayoutView
//    }
//
//    open var searchBars: [UISearchBar] {
//        var searchBars = [searchResultsController.searchBar]
//        if showsSecondarySearchBar { searchBars.append(secondarySearchResultsController.searchBar)}
//        return searchBars
//    }
//
//    open override func style() {
//        super.style()
//        searchBars.forEach{$0.textField?.subviews.first?.cornerRadius = 10.0 }
//    }
//
//    open override func setupDelegates() {
//        super.setupDelegates()
//        searchBars.forEach { $0.delegate = self }
//    }
//
//    open override func createSubviews() {
//        super.createSubviews()
//        switch searchBarPosition {
//        case .header:
//            if showsSecondarySearchBar {
//                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", action: didTapNavigationCancelBar)
//                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", action: didTapNavigationSearchBar)
//            }
//        case .navigationTitle:
//            let searchBarContainer = SearchBarContainerView(contentView: searchResultsController.searchBar, contentInsets: searchBarInsets)
//            searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
//            navigationItem.titleView = searchBarContainer
//
//        default: break
//        }
//    }
//}
//
//open class SearchResultController: NSObject {
//    open var searchBar: UISearchBar = UISearchBar()
//    open var searchHeaderToolBar: UIToolbar = UIToolbar()
//    open var config: SearchResultsViewControllerConfiguration
//    open var resultsViewController: SearchResultsViewController
//    open var preSearchViewController: UIViewController?
//
//    open var lastSearchQuery: String?
//
//    public init(searchBar: UISearchBar = UISearchBar(),
//                searchHeaderToolBar: UIToolbar = UIToolbar(),
//                config: SearchResultsViewControllerConfiguration = SearchResultsViewControllerConfiguration(),
//                resultsViewController: SearchResultsViewController,
//                preSearchViewController: UIViewController? = nil) {
//        self.searchBar = searchBar
//        self.searchHeaderToolBar = searchHeaderToolBar
//        self.config = config
//        self.resultsViewController = resultsViewController
//        self.preSearchViewController = preSearchViewController
//    }
//
//    func clearQuery() {
//        lastSearchQuery = nil
//        searchBar.text = nil
//    }
//}
//
//open class SearchResultsViewControllerConfiguration {
//    open var searchThrottle: Float?
//    open var clearsResultsOnCancel: Bool = true
//    open var restoreSearchStateOnAppearance: Bool = true
//    open var searchBarRegainsFirstResponderOnReappear: Bool = true
//    open var cachesQueryOnResignation: Bool = false
//
//    public init(searchThrottle: Float? = 0.25,
//                clearsResultsOnCancel: Bool? = nil,
//                restoreSearchStateOnAppearance: Bool? = nil,
//                searchBarRegainsFirstResponderOnReappear: Bool? = nil,
//                cachesQueryOnResignation: Bool? = nil) {
//        self.searchThrottle = searchThrottle
//        self.clearsResultsOnCancel =? clearsResultsOnCancel
//        self.restoreSearchStateOnAppearance =? restoreSearchStateOnAppearance
//        self.searchBarRegainsFirstResponderOnReappear =? searchBarRegainsFirstResponderOnReappear
//        self.cachesQueryOnResignation =? cachesQueryOnResignation
//    }
//
//
//}
//fileprivate extension UISearchBar {
//    var searchQuery: String? {
//        return textField?.text.removeEmpty
//    }
//    var hasSearchQuery: Bool {
//        guard let searchQuery = searchQuery else { return false }
//        return true
//    }
//}