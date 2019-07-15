//
//  SearchResultsDisplaying.swift
//  UIKitBase
//
//  Created by Brian Strobach on 6/14/19.
//

import DarkMagic
import Swiftest
import UIKitExtensions

public enum SearchDataSource {
    case remote, local
}

open class SearchResultsDisplayingConfiguration {
    public var loadsSearchResultsImmediately: Bool = true
    public var fetchesResultsWithEmptyQuery: Bool = true
    public var searchDataSourceType: SearchDataSource = .remote
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

public extension SearchResultsDisplaying where Self: UIViewController & PaginationManaged {
    func fetchResults(query: String?) {
        guard let query = query else {
            switch searchDataSourceType {
            case .remote:
                if fetchesResultsWithEmptyQuery {
                    paginator.searchQuery = nil
                    fetchNextPage(firstPage: true)
                }
            case .local:
                assertionFailure()
//                datasource.removeFilter()
//                reloadPaginatableCollectionView(completion: {})
            }
            return
        }
        switch searchDataSourceType {
        case .remote:
//            reset(to: .loading)
            paginator.searchQuery = query
            fetchNextPage(firstPage: true)
        case .local:
            assertionFailure()
//            datasource.filterData(searchQuery: query)
//            reloadPaginatableCollectionView(completion: {})
        }
    }
}
