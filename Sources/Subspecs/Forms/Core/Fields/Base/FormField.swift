//import Actions
/// /
/// /  FormField.swift
/// /  Pods
/// /
/// /  Created by Brian Strobach on 8/8/17.
/// /
/// /
//
import Foundation
import Swiftest

public protocol FormFieldContentViewProvider {
    func getContentView() -> UIView & FormFieldViewProtocol
}

public protocol FormFieldViewProtocol {
    func display(valueDescription: String?)
    func display(validationStatus: ValidationStatus)
    func display(validationFailures: [ValidationFailure])
    func display(title: String)
    func display(placeholder: String?)
    func display(state: FormFieldState)
}

public extension FormFieldViewProtocol {
    func display(valueDescription: String?) {}
    func display(validationStatus: ValidationStatus) {}
    func display(validationFailures: [ValidationFailure]) {}
    func display(title: String) {}
    func display(placeholder: String?) {}
    func display(state: FormFieldState) {}
}

public extension FormFieldViewProtocol where Self: UITextField {
    func display(valueDescription: String?) {
        text = valueDescription
        debugLog("")
    }

    func display(validationStatus: ValidationStatus) {
        debugLog("")
    }

    func display(title: String) {
        debugLog("")
        placeholder = title // Title takes precedence over placeholder in vanilla UITextFields
    }

    func display(placeholder: String?) {
        debugLog("")
        // Do nothing, title takes precedence over placeholder in vanilla UITextFields
    }
}

extension MaterialTextField: FormFieldViewProtocol {}
public extension FormFieldViewProtocol where Self: MaterialTextField {
    func display(valueDescription: String?) {
        debugLog("")
        text = valueDescription
    }

    func display(validationStatus: ValidationStatus) {
        debugLog("")
    }

    func display(validationFailures: [ValidationFailure]) {
        debugLog("")
        errorText = validationFailures.first?.explanationMessage
    }

    func display(title: String) {
        debugLog("")
        self.title = title
    }

    func display(placeholder: String) {
        debugLog("")
        self.placeholder = placeholder
    }
}

public protocol TextDisplayable {
    var text: String { get set }
}

public enum FormFieldState {
    case active, inactive, disabled
}

open class FormField<ContentView: UIView, Value: Any>: AbstractFormField where ContentView: FormFieldViewProtocol {
    override open var behaviors: Set<FormFieldBehavior> {
        didSet {
            updateContentView()
        }
    }

    // Makes accessoryview assignable
    open var _inputAccessoryView: UIView? {
        didSet {
            reloadInputViews()
        }
    }

    override open var inputAccessoryView: UIView? {
        return _inputAccessoryView
    }

    override open var isEnabled: Bool {
        didSet {
            (contentView as? UIControl)?.isEnabled = isEnabled
        }
    }

    open var state: FormFieldState = .inactive

    open var placeholder: String? {
        didSet {
            updateContentView()
        }
    }

    open var title: String = "" {
        didSet {
            updateContentView()
        }
    }

    open var value: Value? {
        didSet {
            updateContentView()
            if validationFrequency == .onValueChanged {
                validate(displayErrors: displayErrorOnNextValidation && validationErrorDisplayFrequency == .onValueChanged)
            }
        }
    }

    override open var hasValue: Bool {
        return value != nil
    }

    open func textDescription(for value: Value?) -> String? {
        guard let value = value else { return nil }
        return "\(value)"
    }

    override open func outputValueToJSON() -> Any? {
        return self.value
    }

    public lazy var contentView: ContentView = self.createContentView()

    open func createContentView() -> ContentView {
        return ContentView(frame: .zero)
    }

    open var usesFieldNameAsPlaceholder: Bool = false
    open var showsValidationErrorMessages: Bool = false

    // MARK: Initialization

    public init(contentView: ContentView? = nil, fieldName: String, title: String? = nil, placeholder: String? = nil, value: Value? = nil) {
        super.init(callInitLifecycle: false)
        self.contentView =? contentView
        self.fieldName = fieldName
        self.title = title ?? fieldName
        self.value =? value
        self.updateContentView()
        initLifecycle(.programmatically)
    }

    override public init(callInitLifecycle: Bool = true) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func initProperties() {
        super.initProperties()
        if self.title.isEmpty { self.title = fieldName }
        if self.usesFieldNameAsPlaceholder { self.placeholder = fieldName }
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.contentView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.contentView.height.greaterThanOrEqual(to: 0)
        self.contentView.horizontalEdges.equal(to: horizontalEdges)
        matchContentHeight(of: self.contentView)
        enforceContentSize()
    }

    override open func setupControlActions() {
        super.setupControlActions()
        addTap { [weak self] _ in
            guard let self = self else { return }
            self.fieldWasTapped()
        }
    }

    open func fieldWasTapped() {
        _ = self.becomeFirstResponder()
    }

    open func proxyFirstResponder() -> UIResponder? {
        if self.contentView.canBecomeFirstResponder {
            return self.contentView
        }
        return nil
    }

    override open func becomeFirstResponder() -> Bool {
        let didRespond = self.proxyFirstResponder()?.becomeFirstResponder() ?? super.becomeFirstResponder()
        if didRespond {
            validationDelegate?.fieldDidBeginEditing(self)
        }
        return didRespond
    }

    override open var isFirstResponder: Bool {
        return proxyFirstResponder()?.isFirstResponder ?? super.isFirstResponder
    }

    override open func resignFirstResponder() -> Bool {
        let didResign = self.proxyFirstResponder()?.resignFirstResponder() ?? super.resignFirstResponder()
        if didResign {
            validationDelegate?.fieldDidEndEditing(self)
        }
        return didResign
    }

    override open var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: Validation

    override open func validationStatusChanged(_ status: ValidationStatus) {
        self.contentView.display(validationStatus: status)
    }

    override open func displayValidationFailures() {
        self.contentView.display(validationFailures: validationFailures)
    }

    func getValidationErrorMessage() -> String? {
        return validationFailures.first?.explanationMessage
    }

    // MARK: Content View Updating

    open func updateContentView() {
        var fullTitle = self.title
        for behavior in self.behaviors {
            switch (behavior, requiresValue) {
            case (.indicatesOptionalFields, false):
                fullTitle += " (optional)"
            case (.indicatesRequiredFields, true):
                fullTitle += " *"
            default: break
            }
        }
        self.contentView.display(title: fullTitle)
        self.contentView.display(placeholder: self.placeholder)
        self.contentView.display(valueDescription: self.textDescription(for: self.value))
    }
}

public extension FormFieldProtocol {
    func getContentView() -> (UIView & FormFieldViewProtocol)? {
        return (self as? FormFieldContentViewProvider)?.getContentView()
    }
}

extension FormField: FormFieldContentViewProvider {
    public func getContentView() -> UIView & FormFieldViewProtocol {
        return self.contentView
    }
}
