/// /
/// /  FormLocationField.swift
/// /  Pods
/// /
/// /  Created by Brian Strobach on 9/8/17.
/// /
/// /
//
// import Foundation
// import UIKit
//
// open class FormLocationField<ContentView: UIView>: FormPickerField<ContentView, LocationData, LocationPickerSearchViewController>
//    where ContentView: FormFieldViewProtocol {
//    open override func initProperties() {
//        super.initProperties()
//        pickerViewController = LocationPickerSearchViewController()
//        contentView.isUserInteractionEnabled = false
//    }
//
//    open override func textDescription(for value: LocationData?) -> String? {
//        var text: String?
//        if let location = value {
//            let city = location.postalAddress.city
//            let state = location.postalAddress.state
//            text = "\(city), \(state)"
//        }
//        return text
//    }
// }
