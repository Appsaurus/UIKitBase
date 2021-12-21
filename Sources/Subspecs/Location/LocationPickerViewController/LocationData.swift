//
//  Location.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import AddressBookUI
import Contacts
import CoreLocation
import Foundation
import Swiftest

public typealias LocationDisplayNameFormatter = (LocationData) -> (title: String?, subtitle: String?)

public class LocationData: NSObject {
    // User set location overrides placemarks location
    public var location: CLLocation
    public var placemark: CLPlacemark?
    public lazy var postalAddress: CNPostalAddress = self.placemark?._postalAddress ?? CNPostalAddress()

    // Used for annotation display
    public var locationDisplayNameFormatter: LocationDisplayNameFormatter?

    public init(location: CLLocation? = nil, placemark: CLPlacemark) {
        self.location = location ?? placemark.location!
        self.placemark = placemark
    }

    public init(location: CLLocation, postalAddress: CNPostalAddress) {
        self.location = location
        super.init()
        self.postalAddress = postalAddress
    }
}

import MapKit

extension LocationData: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
        return self.location.coordinate
    }

    public var title: String? {
        if let formatted = locationDisplayNameFormatter?(self) {
            return formatted.title
        }

        if let placemark = placemark {
            if let name = placemark.name, !name.isEmpty {
                return placemark.name!
            }

            if let address = placemark._postalAddress {
                return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            }
        }

        return "\(self.location.coordinate)"
    }

    public var subtitle: String? {
        if let formatted = locationDisplayNameFormatter?(self) {
            return formatted.subtitle
        }

        if let placemark = placemark {
            if let city = placemark.locality, let state = placemark.administrativeArea, !city.isEmpty, !state.isEmpty {
                return "\(city), \(state)"
            }

            if let postcode = placemark.postalCode, !postcode.isEmpty {
                return postcode
            }
        }

        if let address = placemark?._postalAddress {
            return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
        }

        return "\(self.location.coordinate)"
    }
}

public extension CLPlacemark {
    var _postalAddress: CNPostalAddress? {
        guard #available(iOS 11.0, *) else {
            guard let addressDictionary = addressDictionary else { return nil }
            let address = CNMutablePostalAddress()
            address.street = addressDictionary["Street"] as? String ?? ""
            address.state =? administrativeArea
            address.city =? locality
            address.country =? country
            address.postalCode =? postalCode
            address.isoCountryCode =? isoCountryCode

            if #available(iOS 10.3, *) {
                address.subLocality =? subLocality
                address.subAdministrativeArea =? subAdministrativeArea
            }
            return address
        }
        return postalAddress
    }
}
