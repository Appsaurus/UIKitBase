//
//  PhoneNumberFormViewController.swift
//  OpenApiClient
//
//  Created by Brian Strobach on 10/15/17.
//

import CountryPicker
import PhoneNumberKit
import Swiftest
import UIKitMixinable
import UIKitTheme

public protocol PhoneNumberFormDelegate: AnyObject {
    func processSelected(phoneNumber: PhoneNumber, success: @escaping VoidClosure, failure: @escaping ErrorClosure) // For asyncronous processing or validation, optionally override
    func phoneNumberFormViewController(didSelect phoneNumber: PhoneNumber)
    func phoneNumberFormViewControllerDidCancel()
}

public extension PhoneNumberFormDelegate {
    func processSelected(phoneNumber: PhoneNumber, success: @escaping VoidClosure, failure: @escaping ErrorClosure) { // Make this effectively optional
        success()
    }
}

public struct PhoneNumberFormViewControllerConfiguration {
    public let promptText: String? = "Please enter a phone number."
    public let style: PhoneNumberFormViewControllerStyle = PhoneNumberFormViewControllerStyle()
    public init() {}
}

public class PhoneNumberFormViewControllerStyle {
    open lazy var keyboard: UIKeyboardAppearance = .dark
    open lazy var statusBar: UIStatusBarStyle = .lightContent
    open lazy var navigationBarStyle: NavigationBarStyle = .primary
    open lazy var viewStyle: ViewStyle = ViewStyle(backgroundColor: .primary)
    open lazy var promptLabelStyle: TextStyle = .light(color: .primaryContrast)
    open lazy var textFieldStyles: TextFieldStyleMap = .materialStyleMap(color: .primaryContrast)
    open lazy var submitButtonStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast), viewStyle: ViewStyle(backgroundColor: .success))
    open lazy var submitButtonDisabledStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))
    open lazy var secondaryButtonStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))

    public init() {}
}

extension PhoneNumberFormViewController: BackButtonManaged {}
open class PhoneNumberFormViewController<TextField: UITextField>: FormTableViewController where TextField: FormFieldViewProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [BackButtonManagedMixin(self)]
    }

    open weak var delegate: PhoneNumberFormDelegate?
    open var configuration: PhoneNumberFormViewControllerConfiguration = PhoneNumberFormViewControllerConfiguration()

    var numberField: PhoneNumberFormTextField<TextField> = PhoneNumberFormTextField<TextField>(fieldName: "Phone Number")
    var countryField: PhoneNumberCountryPickerFormField<TextField> = PhoneNumberCountryPickerFormField<TextField>(fieldName: "Country Code")

    internal var phoneNumberString: String {
        return "\(self.countryField.value?.phoneCode ?? "")\(self.numberField.value ?? "")"
    }

    open var phoneNumber: PhoneNumber? {
        return try? PhoneNumberKit().parse(self.phoneNumberString)
    }

    // MARK: Style

//    open var style: PhoneNumberFormViewControllerStyle{
//        return configuration.style
//    }

    open override var headerPromptText: String? {
        return configuration.promptText
    }

    public var defaultNavigationBarStyle: NavigationBarStyle? {
        return configuration.style.navigationBarStyle
    }

    open override func style() {
        super.style()
        view.apply(viewStyle: configuration.style.viewStyle)
        let fields: [UITextField] = [numberField.textField, countryField.textField]

        fields.forEach { (tf: UITextField) in
            switch tf {
            case let stf as StatefulTextField:
                stf.styleMap = configuration.style.textFieldStyles
            default:
                guard let style = configuration.style.textFieldStyles[.active] else { return }
                tf.apply(textFieldStyle: style)
            }

//            if let mf = tf as? MaterialTextField{
//                mf.apply(textFieldStyle: self.style.textFieldStyle)
//            }
//            else{
//            }
        }
    }

    public required init(delegate: PhoneNumberFormDelegate, configuration: PhoneNumberFormViewControllerConfiguration? = nil) {
        super.init(callDidInit: false)
        self.delegate = delegate
        self.configuration =? configuration
        didInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        tableView.hideEmptyCellsAtBottomOfTable()
        tableView.hideSeparatorInset()
        tableView.separatorColor = .clear
        headerPromptLabel?.textAlignment = .center
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = numberField.becomeFirstResponder()
    }

    open func backButtonWillPopViewController() {
        delegate?.phoneNumberFormViewControllerDidCancel()
    }

    open override func createForm() -> Form {
        numberField.validationThrottle = 1.0
        let form = Form(fields: [countryField, numberField])
        form.customValidationCheck = { [weak self] in
            guard let self = self else { return nil }
            guard self.phoneNumber != nil else {
                return ValidationFailure(failureType: .customValidation, explanationMessage: "Invalid phone number.")
            }
            return nil
        }
        form.validate() // Country picker should be valid to begin if the current region code works
        return form
    }

    open override func submit(success: @escaping VoidClosure, failure: @escaping ErrorClosure) {
        guard let delegate = delegate, let phoneNumber = phoneNumber else {
            success()
            return
        }
        delegate.processSelected(phoneNumber: phoneNumber, success: success, failure: failure)
    }

    open override func submissionDidSucceed() {
        super.submissionDidSucceed()
        guard let delegate = delegate, let phoneNumber = phoneNumber else {
            return
        }
        delegate.phoneNumberFormViewController(didSelect: phoneNumber)
    }
}
