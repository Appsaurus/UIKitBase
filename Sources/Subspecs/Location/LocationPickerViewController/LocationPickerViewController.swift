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

open class LocationPickerSearchViewController: SearchViewController, TaskResultDelegate {
    public var result: LocationData?

    public var onDidFinishTask: TaskCompletionClosure? {
        didSet {
            mapViewController.onDidFinishTask = onDidFinishTask
        }
    }

    // MARK: ChildViewControllers

    open var searchConfig = LocationPickerSearchConfiguration()
    open var mapConfig = LocationPickerMapConfiguration()

    public required init(searchConfig: LocationPickerSearchConfiguration? = nil,
                         mapConfig: LocationPickerMapConfiguration? = nil)
    {
        self.searchConfig =? searchConfig
        self.mapConfig =? mapConfig
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    lazy var searchResultsViewController: LocationSearchResultsViewController = {
        let resultsVC = LocationSearchResultsViewController(config: self.searchConfig)
        //        resultsVC.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
        return resultsVC
    }()

    override open func createSearchResultsControllers() -> SearchResultsControllers {
        return SearchResultsControllers(resultsViewController: self.searchResultsViewController,
                                        preSearchViewController: self.mapViewController)
    }

    lazy var mapViewController: LocationPickerMapViewController = {
        let mapVC = LocationPickerMapViewController(config: self.mapConfig)
        return mapVC
    }()

    override open func initProperties() {
        super.initProperties()
        layoutConfig.searchBarPosition = .navigationTitle
        self.mapViewController.onDidFinishTask = self.onDidFinishTask
        self.searchResultsViewController.onDidFinishTask = (result: { [weak self] value in
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

internal typealias LocationPickerMapViewControllerProtocols = TaskResultDelegate & UIGestureRecognizerDelegate & MKMapViewDelegate
open class LocationPickerMapViewController: ConfigurableViewController<LocationPickerMapConfiguration, ViewControllerStyle>, LocationPickerMapViewControllerProtocols {
    public var result: LocationData?

    public typealias TaskResult = LocationData
    public var onDidFinishTask: TaskCompletionClosure?

    public var submitButton: BaseButton!
    public var selectButtonTitle: String {
        return config.selectButtonTitleBuilder.titleFor(location: self.location)
    }

    // MARK: Configuration

    //    open var config: LocationPickerMapConfiguration = LocationPickerMapConfiguration()

    public var mapType: MKMapType = .standard {
        didSet {
            if isViewLoaded {
                self.mapView.mapType = self.mapType
            }
        }
    }

    // MARK: Model

    public var location: LocationData? {
        didSet {
            self.location?.locationDisplayNameFormatter = config.locationDisplayNameFormatter
            self.submitButton.titleMap = [.normal: self.selectButtonTitle]
            updateSubmitButtonState()
            if isViewLoaded {
                self.updateAnnotation()
            }
        }
    }

    // MARK: Views

    var mapView = MKMapView(frame: .zero)

    lazy var currentLocationButton: BaseButton = {
        BaseButton(icon: MaterialIcons.My_Location, buttonLayout: ButtonLayout(layoutType: .titleCentered, marginInsets: .zero))
    }()

    override open func style() {
        super.style()

        let viewStyle: ViewStyle = .raised(backgroundColor: .primary)

        let selectButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast), viewStyle: viewStyle)
        submitButton.apply(buttonStyle: selectButtonStyle)
        self.submitButton.apply(shape: .roundedRect)

        let iconTextStyle = TextStyle(color: .primaryContrast, font: MaterialIcons.font())
        let iconButtonStyle = ButtonStyle(textStyle: iconTextStyle, viewStyle: viewStyle)
        currentLocationButton.apply(buttonStyle: iconButtonStyle)
        self.currentLocationButton.rounded = true
    }

    override open func initProperties() {
        super.initProperties()
        self.mapView.mapType = self.mapType
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let annotation = mapView.annotations.first, let annotationView = mapView.view(for: annotation) else { return }
        annotationView.superview?.bringSubviewToFront(annotationView)
    }

    override open func createSubviews() {
        super.createSubviews()
        view.addSubview(self.mapView)
        self.mapView.addSubview(self.currentLocationButton)
        setupSubmitButton(configuration: ManagedButtonConfiguration(position: .floatingFooter))
        self.submitButton.titleMap = [.normal: self.selectButtonTitle]
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.mapView.pinToSuperview()
        self.currentLocationButton.size.equal(to: 35)
        self.currentLocationButton.topTrailing.equal(to: .inset(25, 25))
    }

    override open func setupControlActions() {
        super.setupControlActions()
        self.currentLocationButton.addAction { [weak self] in
            guard let self = self else { return }
            self.authorize {
                self.currentLocationButton.showActivityIndicator()
                LocationManager.shared.locateFromGPS(.oneShot, accuracy: .neighborhood, result: { [weak self] result in
                    guard let self = self else { return }
                    do {
                        let location = try result.get()
                        debugLog("Found location \(location)")
                        self.currentLocationButton.hideActivityIndicator()
                        self.reversGeocodeAndDropPin(at: location.coordinate)
                    } catch {
                        self.currentLocationButton.hideActivityIndicator()
                        self.showErrorAlert(error)
                    }
                })
            }
        }
    }

    override open func loadAsyncData() {
        super.loadAsyncData()
        if config.dropPinAtInitialLocation {
            LocationManager.shared.locateFromIP(service: .ipAPI) { [weak self] result in
                do {
                    guard let self = self else { return }
                    let location = try result.get()
                    debugLog("Found location \(String(describing: location.coordinates))")

                    self.reversGeocodeAndDropPin(at: location.coordinates!)
                } catch {
                    debugLog("Something bad has occurred \(error)")
                }
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .none
        self.mapView.showsUserLocation = config.dropPinAtInitialLocation || config.showCurrentLocationButton
        self.currentLocationButton.isVisible = config.showCurrentLocationButton
        //        if useCurrentLocationAsHint {
        //            getCurrentLocation()
        //        }
    }

    var presentedInitialLocation = false

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
        if !self.presentedInitialLocation {
            self.setInitialLocation()
            self.presentedInitialLocation = true
        }
    }

    func setInitialLocation() {
        if let location = location {
            // present initial location if any
            self.location = location
            self.showCoordinates(location.coordinate, animated: false)
        } else if config.dropPinAtInitialLocation {
            self.showCurrentLocation(false)
        }
    }

    func currentLocationPressed() {
        self.showCurrentLocation()
    }

    func showCurrentLocation(_ animated: Bool = true) {
        //            self?.showCoordinates(location.coordinate, animated: animated)
    }

    func updateAnnotation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if let location = location {
            self.mapView.addAnnotation(location)
            self.mapView.selectAnnotation(location, animated: true)
        }
    }

    func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let displayRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: config.resultRegionDistance, longitudinalMeters: config.resultRegionDistance)
        self.mapView.setRegion(displayRegion, animated: animated)
    }

    func reversGeocodeAndDropPin(at location: CLLocationCoordinate2D) {
        self.dropPin(at: location)
        LocationManager.shared.locateFromCoordinates(location) { [weak self] result in
            guard let self = self else { return }
            do {
                let places = try result.get()
                debugLog("Found location \(location)")
                self.currentLocationButton.hideActivityIndicator() // In case this was triggered by gps lookup
                guard let placemark = places.first?.placemark else { return }
                self.location = LocationData(location: CLLocation(latitude: location.latitude, longitude: location.longitude), placemark: placemark)
            } catch {
                self.currentLocationButton.hideActivityIndicator()
                self.showErrorAlert(error)
            }
        }
    }

    func dropPin(at coordinate: CLLocationCoordinate2D) {
        // add point annotation to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
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
        pin.rightCalloutAccessoryView = self.selectLocationButton()
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
        self.onDidFinishTask?.result(location)
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
        return self.location != nil
    }

    public func submissionDidSucceed() {
        guard let location = location else { return }
        self.onDidFinishTask?.result(location)
    }
}

// MARK: Selecting location with gesture

extension LocationPickerMapViewController {
    func addLocation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.mapView)
            let coordinates = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            _ = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

            // clean location, cleans out old annotation too
            self.location = nil

            // add point annotation to map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            self.mapView.addAnnotation(annotation)

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
