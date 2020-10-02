//
//  LocationSearchResultsViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import Contacts
import DiffableDataSources
import MapKit
import Swiftest
import SwiftLocation
import UIKit
import UIKitMixinable
open class LocationSearchResultsViewController: PaginatableTableViewController, SearchResultsDisplaying, TaskResultDelegate {
    public var result: LocationData?

    private let locationSearchPaginator = MKLocalSearchRequestQueryPaginator()
    public lazy var paginator: Paginator<MKMapItem> = self.locationSearchPaginator
    public var paginationConfig = PaginationConfiguration()

    public typealias PaginatableModel = MKMapItem

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + PaginationManagedMixin(self)
    }

    public typealias TaskResult = LocationData
    public var onDidFinishTask: TaskCompletionClosure?

    var isShowingHistory = false
    var searchHistoryLabel: String?
    var locationHint: CLLocationCoordinate2D?

    open var config = LocationPickerSearchConfiguration()

    public init(config: LocationPickerSearchConfiguration = LocationPickerSearchConfiguration(), locationHint: CLLocationCoordinate2D? = nil) {
        self.config = config
        self.locationHint = locationHint
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public lazy var datasource = TableViewDiffableDataSource<String, MKMapItem>(tableView: tableView) { tableView, _, mapItem in
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LocationCell")
        let location = mapItem.toLocation()
        cell.textLabel?.text = location.title
        cell.detailTextLabel?.text = location.subtitle
        return cell
    }

    override open func initProperties() {
        super.initProperties()
        self.paginator = self.locationSearchPaginator
    }

    override open func didInit(type: InitializationType) {
        super.didInit(type: type)
        if let location = locationHint {
            self.locationSearchPaginator.locationHint = location
        } else {
            LocationManager.shared.locateFromIP(service: .ipAPI) { [weak self] result in
                guard let self = self else { return }
                do {
                    guard let location = try result.get().coordinates else { return }
                    debugLog("Setting search location hint \(location)")
                    self.locationSearchPaginator.locationHint = location
                } catch {
                    debugLog("Something bad has occurred \(error)")
                }
            }
        }
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onDidFinishTask?.result(LocationData(placemark: self.datasource[indexPath].placemark))
    }

    open func reloadDidBegin() {}

    open func didReload() {}
}

extension MKMapItem {
    public func toLocation() -> LocationData {
        return LocationData(placemark: placemark)
    }
}

class MKLocalSearchRequestQueryPaginator: Paginator<MKMapItem> {
    // }
//
    // func showItemsForSearchResult(_ searchResult: MKLocalSearchResponse?) {
//    results.locations = searchResult?.mapItems.map { Location(name: $0.name, placemark: $0.placemark) } ?? []
//    results.isShowingHistory = false
//    results.tableView.reloadData()
    // }
    var localSearch: MKLocalSearch?
    public var locationHint: CLLocationCoordinate2D?
    deinit {
        localSearch?.cancel()
    }

    override func fetchNextPage(success: @escaping ((items: [MKMapItem], isLastPage: Bool)) -> Void, failure: @escaping ErrorClosure) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        if let location = locationHint {
            request.region = MKCoordinateRegion(center: location,
                                                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        }

        self.localSearch?.cancel()
        self.localSearch = MKLocalSearch(request: request)
        self.localSearch!.start { response, error in
            guard error == nil else {
                failure(error!)
                return
            }
            guard let items: [MKMapItem] = response?.mapItems else {
                failure(NSError())
                return
            }

            success((items, true))
        }
    }
}
