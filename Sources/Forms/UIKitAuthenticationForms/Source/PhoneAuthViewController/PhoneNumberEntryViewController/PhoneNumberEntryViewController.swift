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
    func processSelected(phoneNumber: PhoneNumber, resultClosure: @escaping ResultClosure<Any?>) // For asyncronous processing or validation, optionally override
    func phoneNumberFormViewController(didSelect phoneNumber: PhoneNumber)
    func phoneNumberFormViewControllerDidCancel()
}

public extension PhoneNumberFormDelegate {
    func processSelected(phoneNumber: PhoneNumber, resultClosure: @escaping ResultClosure<Any?>) { // Make this effectively optional
        resultClosure(.success(nil))
    }
}

public struct PhoneNumberFormViewControllerConfiguration {
    public let promptText: String? = "Please enter a phone number."
    public let style = PhoneNumberFormViewControllerStyle()
    public init() {}
}

public class PhoneNumberFormViewControllerStyle {
    open lazy var keyboard: UIKeyboardAppearance = .dark
    open lazy var statusBar: UIStatusBarStyle = .lightContent
    open lazy var navigationBarStyle: NavigationBarStyle = .primary
    open lazy var viewStyle = ViewStyle(backgroundColor: .primary)
    open lazy var promptLabelStyle: TextStyle = .light(color: .primaryContrast)
    open lazy var textFieldStyles: TextFieldStyleMap = .materialStyleMap(color: .primaryContrast)
    open lazy var submitButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast), viewStyle: ViewStyle(backgroundColor: .success))
    open lazy var submitButtonDisabledStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))
    open lazy var secondaryButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))

    public init() {}
}

extension PhoneNumberFormViewController: BackButtonManaged {}
open class PhoneNumberFormViewController<TextField: UITextField>: FormTableViewController<PhoneNumber, Any?> where TextField: FormFieldViewProtocol {
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + [BackButtonManagedMixin(self)]
    }

    open weak var delegate: PhoneNumberFormDelegate?
    open var configuration = PhoneNumberFormViewControllerConfiguration()

    var numberField = PhoneNumberFormTextField<TextField>(fieldName: "Phone Number")
    var countryField = PhoneNumberCountryPickerFormField<TextField>(fieldName: "Country Code")

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

    override open var headerPromptText: String? {
        return self.configuration.promptText
    }

    public var defaultNavigationBarStyle: NavigationBarStyle? {
        return configuration.style.navigationBarStyle
    }

    override open func style() {
        super.style()
        view.apply(viewStyle: self.configuration.style.viewStyle)
        let fields: [UITextField] = [numberField.textField, self.countryField.textField]

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
        super.init(callInitLifecycle: false)
        self.delegate = delegate
        self.configuration =? configuration
        initLifecycle(.programmatically)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        tableView.hideEmptyCellsAtBottomOfTable()
        tableView.hideSeparatorInset()
        tableView.separatorColor = .clear
        headerPromptLabel?.textAlignment = .center
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = self.numberField.becomeFirstResponder()
    }

    open func backButtonWillPopViewController() {
        self.delegate?.phoneNumberFormViewControllerDidCancel()
    }

    override open func createForm() -> Form {
        self.numberField.validationThrottle = 1.0
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

    override open func submit(_ submission: PhoneNumber, _ resultClosure: @escaping (Result<Any?, Error>) -> Void) {
        guard let delegate = delegate, let phoneNumber = phoneNumber else {
            resultClosure(.success(nil))
            return
        }

        delegate.processSelected(phoneNumber: phoneNumber, resultClosure: resultClosure)
    }

    override open func submissionDidSucceed(with response: Any?) {
        super.submissionDidSucceed(with: response)
        guard let delegate = delegate, let phoneNumber = phoneNumber else {
            return
        }
        delegate.phoneNumberFormViewController(didSelect: phoneNumber)
    }
}
