//
//  SearchViewController.swift
//  Pods
//
//  Created by Brian Strobach on 3/13/17.
//
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

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

public enum SearchBarPosition{
	case navigationTitle, header
}

//public enum SearchBarAppearanceResponderBehavior{
//	case alwaysRegainFirstResponder
//	case regainFirstResponderIfQueryPresent
//	case neverRegainFirstResponder
//}

public enum SearchDataSource{
	case paginator, localDatasource
}
open class SearchViewController<ModelType: Paginatable>: BaseParentViewController, UISearchBarDelegate{

	open lazy var preSearchViewController: UIViewController? = nil

	open lazy var searchResultsTableViewController: PaginatableTableViewController<ModelType> = {
		let searchVC = self.createSearchResultsTableViewController()
		searchVC.loadsResultsImmediately = self.fetchesResultsWithEmptyQuery
		return searchVC
	}()

	open lazy var searchBar: UISearchBar = UISearchBar()
	open lazy var searchHeaderToolBar: UIToolbar = UIToolbar()
	open lazy var searchLayoutView: UIView = {
		let searchLayoutView = UIView()
		let searchViews: [UIView] = [searchBar, searchHeaderToolBar]
		searchLayoutView.addSubviews(searchViews)
        searchViews.stack(.leadingToTrailing, in: searchLayoutView)
		return searchLayoutView
	}()


	//MARK: SearchBar layout configuration //TODO: Refactor this into single layout config class
	open lazy var searchBarPosition: SearchBarPosition = .header
	open lazy var searchBarInsets: UIEdgeInsets = .zero //This can mess with corner radius of search bar's text field, may need to tweak accordingly


	//MARK: SearchBar layout configuration //TODO: Refactor this into single search config class
	open lazy var searchDataSource: SearchDataSource = .paginator
	open lazy var searchThrottle: Float? = 0.25
	open lazy var fetchesResultsWithEmptyQuery: Bool = false
	open lazy var clearsResultsOnCancel: Bool = true
	open lazy var restoreSearchStateOnAppearance: Bool = true
	open lazy var searchBarRegainsFirstResponderOnReappear: Bool = true
	open lazy var cachesQueryOnResignation: Bool = false
	open var lastSearchQuery: String?

	open var userHasEnteredSearchQuery: Bool{
		return searchQuery != nil
	}
	open var searchQuery: String? {
		return searchBar.textField?.text.removeEmpty
	}

	open func createSearchResultsTableViewController() -> PaginatableTableViewController<ModelType>{
		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
		return PaginatableTableViewController<ModelType>()
	}

	open override func initialChildViewController() -> UIViewController {
		return preSearchViewController ?? searchResultsTableViewController
	}

	open override func createHeaderView() -> UIView? {
		guard searchBarPosition == .header else{
			return nil
		}
		return searchLayoutView
	}
	open override func style() {
		super.style()
		searchBar.textField?.subviews.first?.cornerRadius = 10.0
	}
	open override func didInit() {
		super.didInit()
	}

    open override func setupDelegates() {
        super.setupDelegates()
        searchBar.delegate = self
    }

	open override func createSubviews() {
		super.createSubviews()
		switch searchBarPosition{
		case .navigationTitle:
			let searchBarContainer = SearchBarContainerView(contentView: searchBar, contentInsets: searchBarInsets)
			searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
			navigationItem.titleView = searchBarContainer

		default: break
		}
	}

	private var searchBarWasActiveWhenLastVisible: Bool = false

	open override func viewWillDisappear(_ animated: Bool){
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

	open func queryInputChanged(){

		if searchDataSource == .paginator{
			searchResultsTableViewController.reset(to: .loading)
		}

		guard let query = searchQuery else{
			switch searchDataSource{
			case .paginator:
				if fetchesResultsWithEmptyQuery{
					searchResultsTableViewController.activePaginator.searchQuery = nil
					searchResultsTableViewController.fetchNextPage(firstPage: true)
				}
			case .localDatasource:
				searchResultsTableViewController.dataSource.removeFilter()
				searchResultsTableViewController.tableView.reloadData()
			}
			return
		}


		guard let searchThrottle = searchThrottle else {
			performSearch(query: query)
			return
		}

		// Throttle network activity
		let performSearchSelector = #selector(SearchViewController.triggerSearch)
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: performSearchSelector, object: nil)
		self.perform(performSearchSelector, with: nil, afterDelay: TimeInterval(searchThrottle))
	}

	@objc private func triggerSearch(){
		guard let query = searchQuery else{
			return
		}
		performSearch(query: query)
	}

	open func performSearch(query: String){
		DispatchQueue.main.async {
			switch self.searchDataSource{
			case .paginator:
				self.searchResultsTableViewController.activePaginator.searchQuery = query
				self.searchResultsTableViewController.fetchNextPage(firstPage: true)
			case .localDatasource:
				self.searchResultsTableViewController.dataSource.filterData(searchQuery: query)
				self.searchResultsTableViewController.tableView.reloadData()
			}
		}
	}

	open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		resignSearch()

	}

	open func resignSearch(forceClearQuery: Bool? = nil){
		DispatchQueue.main.async {
			let clearQuery = forceClearQuery ?? self.clearsResultsOnCancel
			self.resignSearchBar(forceClearQuery: clearQuery)
			self.hideSearchResultsViewController() //If there is a preSearchViewController, swap it back in
		}
	}


	open func hideSearchResultsViewController(){

		guard let preSearchViewController = preSearchViewController, preSearchViewController != children.first else {
			return
		}

		swap(out: searchResultsTableViewController,
             with: preSearchViewController,
             into: containerView,
			 completion: { [weak self] in
				guard let sSelf = self else { return }
				sSelf.searchResultsTableViewController.transition(to: sSelf.searchResultsTableViewController.currentState)
		})
	}
	open func resignSearchBar(forceClearQuery: Bool = false){
		if cachesQueryOnResignation{
			lastSearchQuery = searchBar.text
		}
		if forceClearQuery{
			clearSearchQuery()
			queryInputChanged()
		}
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.resignFirstResponder()
	}

	open func resetSearch(){
		resignSearch(forceClearQuery: true)
		searchBarWasActiveWhenLastVisible = false
	}
	open func clearSearchQuery(){
		lastSearchQuery = nil
		searchBar.text = nil
	}

	open func resignSearchBarIfActive(forceClearQuery: Bool = false){
		if searchBar.isFirstResponder{
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
				guard let `self` = self else { return }
				self.restorePreviousSearchState()

		})
	}

	open func restorePreviousSearchState(makeSearchBarFirstResponder: Bool = false){
		if let query = self.lastSearchQuery, self.searchBar.text != query{
			self.searchBar.text = query
			self.queryInputChanged()
		}
		if makeSearchBarFirstResponder { searchBar.becomeFirstResponder() }
		self.searchBar.setShowsCancelButton(searchBar.isFirstResponder, animated: false)
	}
}
