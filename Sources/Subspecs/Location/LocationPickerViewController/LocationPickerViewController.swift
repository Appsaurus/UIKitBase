//
//  LocationPickerViewController.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import Actions
import CoreLocation
import Layman
import MapKit
import Permission
import Swiftest
import SwiftLocation
import UIFontIcons
import UIKitExtensions
import UIKitTheme

open class LocationPickerSearchConfiguration {
    public init() {}
    public var useCurrentLocationAsHint = false
    public var searchBarPlaceholder = "Search or enter an address"
    public var searchHistoryLabel = "Search History"
}

open class LocationPickerSearchViewController: SearchViewController<MKMapItem>, AsyncTaskDelegate {
    public typealias TaskResult = LocationData
    public var onDidFinishTask: TaskCompletionClosure? {
        didSet {
            mapViewController.onDidFinishTask = onDidFinishTask
        }
    }

    // MARK: ChildViewControllers

    open var searchConfig = LocationPickerSearchConfiguration()
    open var mapConfig = LocationPickerMapConfiguration()

    public required init(searchConfig: LocationPickerSearchConfiguration? = nil,
                         mapConfig: LocationPickerMapConfiguration? = nil) {
        self.searchConfig =? searchConfig
        self.mapConfig =? mapConfig
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    lazy var searchResultsViewController: LocationSearchResultsViewController = {
        let resultsVC = LocationSearchResultsViewController(config: self.searchConfig)
        //		resultsVC.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
        return resultsVC
    }()

    open override func createSearchResultsTableViewController() -> PaginatableTableViewController<MKMapItem> {
        return searchResultsViewController
    }

    lazy var mapViewController: LocationPickerMapViewController = {
        let mapVC = LocationPickerMapViewController(config: self.mapConfig)
        return mapVC
    }()

    open override func initProperties() {
        super.initProperties()
        preSearchViewController = mapViewController
        searchBarPosition = .navigationTitle
        mapViewController.onDidFinishTask = onDidFinishTask
        searchResultsViewController.onDidFinishTask = (result: { [weak self] value in
            guard let self = self else { return }
            self.resignSearch()
            self.mapViewController.location = value
        }, cancelled: {})
    }
}

public typealias SelectButtonTitleFormatter = (LocationData?) -> String
public enum SelectButtonTitleBuilder {
    case staticTitle(title: String)
    case dynamicTitle(formatter: SelectButtonTitleFormatter)

    func titleFor(location: LocationData?) -> String {
        switch self {
        case let .staticTitle(title):
            return title
        case let .dynamicTitle(formatter):
            return formatter(location)
        }
    }
}

open class LocationPickerMapConfiguration: ViewControllerConfiguration {
    /// default: true
    public var showCurrentLocationButton = true

    /// default: true
    public var dropPinAtInitialLocation = true

    /// default: "Select"
    public var selectButtonTitleBuilder: SelectButtonTitleBuilder = .staticTitle(title: "Select Location")

    public var resultRegionDistance: CLLocationDistance = 600

    public var locationDisplayNameFormatter: LocationDisplayNameFormatter?
}

internal typealias LocationPickerMapViewControllerProtocols = AsyncTaskDelegate & UIGestureRecognizerDelegate & MKMapViewDelegate
open class LocationPickerMapViewController: ConfigurableViewController<LocationPickerMapConfiguration, ViewControllerStyle>, LocationPickerMapViewControllerProtocols {
    public typealias TaskResult = LocationData
    public var onDidFinishTask: TaskCompletionClosure?

    public var submitButton: BaseButton!
    public var selectButtonTitle: String {
        return config.selectButtonTitleBuilder.titleFor(location: location)
    }

    // MARK: Configuration

    //    open var config: LocationPickerMapConfiguration = LocationPickerMapConfiguration()

    public var mapType: MKMapType = .standard {
        didSet {
            if isViewLoaded {
                mapView.mapType = mapType
            }
        }
    }

    // MARK: Model

    public var location: LocationData? {
        didSet {
            location?.locationDisplayNameFormatter = config.locationDisplayNameFormatter
            submitButton.titleMap = [.normal: selectButtonTitle]
            updateSubmitButtonState()
            if isViewLoaded {
                updateAnnotation()
            }
        }
    }

    // MARK: Views

    var mapView: MKMapView = MKMapView(frame: .zero)

    lazy var currentLocationButton: BaseButton = {
        BaseButton(icon: MaterialIcons.My_Location, buttonLayout: ButtonLayout(layoutType: .titleCentered, marginInsets: .zero))
    }()

    open override func style() {
        super.style()

        let viewStyle: ViewStyle = .raised(backgroundColor: .primary)

        let selectButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast), viewStyle: viewStyle)
        submitButton.apply(buttonStyle: selectButtonStyle)
        submitButton.apply(shape: .roundedRect)

        let iconTextStyle = TextStyle(color: .primaryContrast, font: MaterialIcons.font())
        let iconButtonStyle = ButtonStyle(textStyle: iconTextStyle, viewStyle: viewStyle)
        currentLocationButton.apply(buttonStyle: iconButtonStyle)
        currentLocationButton.rounded = true
    }

    open override func initProperties() {
        super.initProperties()
        mapView.mapType = mapType
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let annotation = mapView.annotations.first, let annotationView = mapView.view(for: annotation) else { return }
        annotationView.superview?.bringSubviewToFront(annotationView)
    }

    open override func createSubviews() {
        super.createSubviews()
        view.addSubview(mapView)
        mapView.addSubview(currentLocationButton)
        setupSubmitButton(configuration: ManagedButtonConfiguration(position: .floatingFooter))
        submitButton.titleMap = [.normal: selectButtonTitle]
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        mapView.pinToSuperview()
        currentLocationButton.size.equal(to: 35)
        currentLocationButton.topTrailing.equal(to: .inset(25, 25))
    }

    open override func setupControlActions() {
        super.setupControlActions()
        currentLocationButton.addAction { [weak self] in
            guard let self = self else { return }
            self.authorize {
                self.currentLocationButton.showActivityIndicator()
                Locator.currentPosition(accuracy: .neighborhood, onSuccess: { [weak self] location in
                    self?.currentLocationButton.hideActivityIndicator()
                    self?.reversGeocodeAndDropPin(at: location)
                }, onFail: { [weak self] error, _ in
                    self?.currentLocationButton.hideActivityIndicator()
                    self?.showErrorAlert(error)
                })
            }
        }
    }

    open override func startLoading() {
        super.startLoading()
        currentLocationButton.isVisible = config.showCurrentLocationButton
        if config.dropPinAtInitialLocation {
            Locator.currentPosition(usingIP: .freeGeoIP, onSuccess: { [weak self] location in
                guard let self = self else { return }
                debugLog("Found location \(location)")
                self.reversGeocodeAndDropPin(at: location)
            }, onFail: { error, _ in
                debugLog("Something bad has occurred \(error)")
            })
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = config.dropPinAtInitialLocation || config.showCurrentLocationButton

        //        if useCurrentLocationAsHint {
        //            getCurrentLocation()
        //        }
    }

    var presentedInitialLocation = false

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
        if !presentedInitialLocation {
            setInitialLocation()
            presentedInitialLocation = true
        }
    }

    func setInitialLocation() {
        if let location = location {
            // present initial location if any
            self.location = location
            showCoordinates(location.coordinate, animated: false)
        } else if config.dropPinAtInitialLocation {
            showCurrentLocation(false)
        }
    }

    func currentLocationPressed() {
        showCurrentLocation()
    }

    func showCurrentLocation(_ animated: Bool = true) {
        //            self?.showCoordinates(location.coordinate, animated: animated)
    }

    func updateAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        if let location = location {
            mapView.addAnnotation(location)
            mapView.selectAnnotation(location, animated: true)
        }
    }

    func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let displayRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: config.resultRegionDistance, longitudinalMeters: config.resultRegionDistance)
        mapView.setRegion(displayRegion, animated: animated)
    }

    func reversGeocodeAndDropPin(at location: CLLocation) {
        dropPin(at: location.coordinate)
        Locator.location(fromCoordinates: location.coordinate, using: .apple, onSuccess: { [weak self] places in
            guard let self = self else { return }
            self.currentLocationButton.hideActivityIndicator() // In case this was triggered by gps lookup
            guard let placemark = places.first?.placemark else { return }
            self.location = LocationData(location: location, placemark: placemark)
        }, onFail: { [weak self] error in
            self?.currentLocationButton.hideActivityIndicator()
            self?.showErrorAlert(error)
        })
    }

    func dropPin(at coordinate: CLLocationCoordinate2D) {
        // add point annotation to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

    func authorize(locationRequest: @escaping VoidClosure) {
        let permission: Permission = .locationWhenInUse

        let disabledAlert = permission.disabledAlert
        disabledAlert.title = "Location services disabled."
        disabledAlert.message = "Please enable location services in iOS settings."
        disabledAlert.cancel = "Ok"

        let deniedAlert = permission.deniedAlert
        deniedAlert.title = "Update permissions."
        deniedAlert.message = "Looks like you previously denied permission to location services. Please update permissions in iOS settings."
        deniedAlert.cancel = "Cancel"
        deniedAlert.settings = "Go to Settings"

        permission.request { [weak self] status in
            guard self != nil else { return }
            switch status {
            case .authorized:
                locationRequest()
            case .denied: print("denied")
            case .disabled: print("disabled")
            case .notDetermined: print("not determined")
            }
        }
    }

    // MARK: MKMapViewDelegate

    @nonobjc public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        pin.pinTintColor = .green
        // drop only on long press gesture
        let fromLongPress = annotation is MKPointAnnotation
        pin.animatesDrop = fromLongPress
        pin.rightCalloutAccessoryView = selectLocationButton()
        pin.canShowCallout = true
        return pin
    }

    func selectLocationButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        button.setTitle("Select", for: .normal)
        if let titleLabel = button.titleLabel {
            let width = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
            button.frame.size = CGSize(width: width, height: 30.0)
        }
        button.setTitleColor(view.tintColor, for: .normal)
        return button
    }

    @nonobjc public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let location = location else { return }
        onDidFinishTask?.result(location)
    }

    @nonobjc public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
        assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")

        if let userPin = views.first(where: { $0.annotation is MKUserLocation }) {
            userPin.canShowCallout = false
        }
    }

    // MARK: UIGestureRecognizerDelegate

    @nonobjc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension LocationPickerMapViewController: SubmitButtonManaged {
    // MARK: SubmitButtonManaged

    public func userCanSubmit() -> Bool {
        return location != nil
    }

    public func submissionDidSucceed() {
        guard let location = location else { return }
        onDidFinishTask?.result(location)
    }
}

// MARK: Selecting location with gesture

extension LocationPickerMapViewController {
    func addLocation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
            _ = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

            // clean location, cleans out old annotation too
            location = nil

            // add point annotation to map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)

            //            geocoder.cancelGeocode()
            //            geocoder.reverseGeocodeLocation(location) { response, error in
            //                if let error = error as? NSError, error.code != 10 { // ignore cancelGeocode errors
            //                    // show error and remove annotation
            //                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            //                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
            //                    self.present(alert, animated: true) {
            //                        self.mapView.removeAnnotation(annotation)
            //                    }
            //                } else if let placemark = response?.first {
            //                    // get POI name from placemark if any
            //                    let name = placemark.areasOfInterest?.first
            //
            //                    // pass user selected location too
            //                    self.location = Location(name: name, location: location, placemark: placemark)
            //                }
            //            }
        }
    }
}
