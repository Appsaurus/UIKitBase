//
//  LocationSearchResultsViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

 import Contacts
 import MapKit
 import Swiftest
 import SwiftLocation
 import UIKit
 import UIKitMixinable

 open class LocationSearchResultsViewController: PaginatableTableViewController, SearchResultsDisplaying, AsyncTaskDelegate {

    public typealias PaginatableModel = MKMapItem
    public typealias TaskResult = LocationData
    public var onDidFinishTask: TaskCompletionClosure?

    var isShowingHistory = false
    var searchHistoryLabel: String?
    var locationHint: CLLocationCoordinate2D?

    open var config: LocationPickerSearchConfiguration = LocationPickerSearchConfiguration()

    public init(config: LocationPickerSearchConfiguration = LocationPickerSearchConfiguration(), locationHint: CLLocationCoordinate2D? = nil) {
        self.config = config
        self.locationHint = locationHint
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private let locationSearchPaginator = MKLocalSearchRequestQueryPaginator()
    open override func initProperties() {
        super.initProperties()
        paginators.paginator = locationSearchPaginator
    }

    open override func didInit(type: InitializationType) {
        super.didInit(type: type)
        if let location = locationHint {
            locationSearchPaginator.locationHint = location
        } else {
            Locator.currentPosition(usingIP: .freeGeoIP, onSuccess: { [weak self] location in
                guard let self = self else { return }
                debugLog("Setting search location hint \(location)")
                self.locationSearchPaginator.locationHint = location.coordinate
            }, onFail: { error, _ in
                debugLog("Something bad has occurred \(error)")
            })
        }
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LocationCell")

        let location = dataSource[indexPath.row]!.toLocation()
        cell.textLabel?.text = location.title
        cell.detailTextLabel?.text = location.subtitle
        return cell
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pm = dataSource[indexPath]!

        onDidFinishTask?.result(LocationData(placemark: pm.placemark))
    }
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

        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch!.start { response, error in
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
