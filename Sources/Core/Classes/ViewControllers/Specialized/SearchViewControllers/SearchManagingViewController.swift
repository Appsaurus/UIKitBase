//
//  PaginatableSearchManagingViewController.swift
//  AppsauruUIKit
//
//  Created by Brian Strobach on 1/13/17.
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import Swiftest
import UIKitTheme
import Layman


open class LocalSearchManagingViewController<ModelType: Paginatable>: BaseParentViewController, UISearchBarDelegate{


	open lazy var tableViewController: PaginatableTableViewController<ModelType> = {
		return self.createTableViewController()
	}()

	open var searchBar: UISearchBar = UISearchBar()
	open var searchBecomesFirstResponder: Bool = true

	open var userHasEnteredSearchQuery: Bool{
		return searchQuery != nil
	}
	open var searchQuery: String? {
		return searchBar.textField?.text.removeEmpty
	}

	open func createTableViewController() -> PaginatableTableViewController<ModelType>{
		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
		return PaginatableTableViewController<ModelType>()
	}


	open override func initialChildViewController() -> UIViewController {
		return tableViewController
	}

	open override func createHeaderView() -> UIView? {
		return searchBar
	}

	override open func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self
	}

	open func queryInputChanged(){
		guard let query = searchQuery else{
			tableViewController.dataSource.removeFilter()
			tableViewController.tableView.reloadData()
			return
		}
		performSearch(query: query)
	}

	open func performSearch(query: String){
		tableViewController.dataSource.filterData(searchQuery: query)
		tableViewController.tableView.reloadData()
	}



	open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
	}


	open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
		tableViewController.dataSource.removeFilter()
		tableViewController.tableView.reloadData()
		view.endEditing(true)
	}

	open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		queryInputChanged()
	}

	open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		queryInputChanged()
		searchBar.resignFirstResponder()
	}
}


open class RemoteSearchManagingViewController<ModelType: Paginatable>: BaseParentViewController, UISearchBarDelegate{

	open lazy var searchResultsTableViewController: PaginatableTableViewController<ModelType> = {
		let searchVC = self.createSearchResultsTableViewController()
		searchVC.loadsResultsImmediately = self.fetchesResultsWithEmptyQuery
		return searchVC
	}()

	open var searchBar: UISearchBar = UISearchBar()
	open var searchThrottle: Float? = 0.25
	open var searchBecomesFirstResponder: Bool = true
	open var fetchesResultsWithEmptyQuery: Bool = false

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
		return searchResultsTableViewController
	}

	open override func createHeaderView() -> UIView? {
		return searchBar
	}

	override open func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self
	}

	open func queryInputChanged(){

		searchResultsTableViewController.transition(to: .loading)

		guard let query = searchQuery else{
			if fetchesResultsWithEmptyQuery{
				searchResultsTableViewController.paginator.searchQuery = nil
				searchResultsTableViewController.fetchNextPage(firstPage: true)
			}
			else{
				searchResultsTableViewController.reset()
			}
			return
		}


		guard let searchThrottle = searchThrottle else {
			performSearch(query: query)
			return
		}

		// Throttle network activity
		let performSearchSelector = #selector(RemoteSearchManagingViewController.triggerSearch)
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
		searchResultsTableViewController.paginator.searchQuery = query
		searchResultsTableViewController.fetchNextPage(firstPage: true)
	}

	//Dismiss keyboard when in search mode and user taps outside of search
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.text = nil
		searchBar.resignFirstResponder()
		searchResultsTableViewController.reset()
	}

	open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		queryInputChanged()
	}

	open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		queryInputChanged()
		searchBar.resignFirstResponder()
	}
}


open class PaginatableSearchManagingViewController<ModelType: Paginatable>: RemoteSearchManagingViewController<ModelType>{


	open lazy var tableViewController: PaginatableTableViewController<ModelType> = {
		return self.createTableViewController()
	}()

	open var clearsResultsOnCancel: Bool = false
	open var lastSearchQuery: String?

	open func createTableViewController() -> PaginatableTableViewController<ModelType>{
		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
		return PaginatableTableViewController<ModelType>()
	}

	open override func initialChildViewController() -> UIViewController {
		return tableViewController
	}

	open override func createHeaderView() -> UIView? {
		return searchBar
	}

	open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        swap(out: tableViewController,
             with: searchResultsTableViewController,
             into: containerView,
			 completion: { [weak self] in
				guard let sSelf = self else { return }
				if !sSelf.clearsResultsOnCancel{
					searchBar.text = sSelf.lastSearchQuery
				}
				sSelf.searchBar.setShowsCancelButton(true, animated: true)
		})
	}

	//Dismiss keyboard when in search mode and user taps outside of search
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	open override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
		if !clearsResultsOnCancel{
			lastSearchQuery = searchBar.text
		}
		else{
			searchResultsTableViewController.reset()
		}
		searchBar.text = nil
		searchBar.resignFirstResponder()

		searchBar.setShowsCancelButton(false, animated: true)
		swap(out: searchResultsTableViewController,
             with: tableViewController,
             into: containerView,
			 completion: { [weak self] in
				guard let sSelf = self else { return }
				sSelf.tableViewController.transition(to: sSelf.tableViewController.currentState)
		})
	}
}
