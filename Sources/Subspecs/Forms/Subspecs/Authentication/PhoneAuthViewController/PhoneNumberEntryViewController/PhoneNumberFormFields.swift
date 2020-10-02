//
//  PhoneNumberFormFields.swift
//  OpenApiClient
//
//  Created by Brian Strobach on 10/6/17.
//

import CountryPicker
import PhoneNumberKit
import Swiftest
import UIKit
import UIKitMixinable

open class PhoneNumberFormTextField<ContentView: UITextField>: FormTextField<ContentView, String> where ContentView: FormFieldViewProtocol {
    override open func initProperties() {
        super.initProperties()
        keyboardType = .numberPad
    }

    override open func setupValidationRules() {
        super.setupValidationRules()
        validationThrottle = 0.3
    }
}

open class PhoneNumberCountry {
    public let name: String
    public let countryCode: String
    public let phoneCode: String
    public let flag: UIImage
    public init(name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.name = name
        self.countryCode = countryCode
        self.phoneCode = phoneCode
        self.flag = flag
    }
}

open class PhoneNumberCountryPickerFormField<T: UITextField>: FormTextField<T, PhoneNumberCountry>, CountryPickerDelegate where T: FormFieldViewProtocol {
    open lazy var flagImageView = UIImageView()

    fileprivate lazy var countryPicker: CountryPicker = {
        let picker = CountryPicker()
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        return picker
    }()

    override open var inputView: UIView? {
        return countryPicker
    }

    override open func updateContentView() {
        super.updateContentView()
        self.display(object: value)
    }

    public func display(object: PhoneNumberCountry?) {
        guard let country = object else {
            return
        }
        self.flagImageView.image = country.flag
        contentView.text = country.phoneCode + " (\(country.name))"
    }

    override open func initProperties() {
        super.initProperties()
        disableUserTextEntry = true
        self.countryPicker.setCountry(Locale.current.regionCode ?? "")
    }

    override open func didInit(type: InitializationType) {
        super.didInit(type: type)
        self.reloadInputViews()
    }

    override open func createSubviews() {
        super.createSubviews()
        let flagHeight = 30.0.cgFloat.scaledForDevice()
        let size = CGSize(width: flagHeight * (5.0 / 3.0), height: flagHeight)
        let insets = UIEdgeInsets(t: 10, l: 0, b: 25, r: 0)
        contentView.setupAccessoryView(self.flagImageView, position: .right, viewMode: .always, insets: insets, size: size)
    }

    override open func reloadInputViews() {
        contentView.inputView = self.inputView
        super.reloadInputViews()
    }

//    open override func textDescription(for value: PhoneNumberCountry?) -> String? {
//        return value?.phoneCode
//    }

    public func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        value = PhoneNumberCountry(name: name, countryCode: countryCode, phoneCode: phoneCode, flag: flag)
    }
}
