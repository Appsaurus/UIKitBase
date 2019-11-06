import Actions
////
////  FormField.swift
////  Pods
////
////  Created by Brian Strobach on 8/8/17.
////
////
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

extension FormFieldViewProtocol {
    public func display(valueDescription: String?) {}
    public func display(validationStatus: ValidationStatus) {}
    public func display(validationFailures: [ValidationFailure]) {}
    public func display(title: String) {}
    public func display(placeholder: String?) {}
    public func display(state: FormFieldState) {}
}

extension FormFieldViewProtocol where Self: UITextField {
    public func display(valueDescription: String?) {
        text = valueDescription
        debugLog("")
    }

    public func display(validationStatus: ValidationStatus) {
        debugLog("")
    }

    public func display(title: String) {
        debugLog("")
        placeholder = title // Title takes precedence over placeholder in vanilla UITextFields
    }

    public func display(placeholder: String?) {
        debugLog("")
        // Do nothing, title takes precedence over placeholder in vanilla UITextFields
    }
}

extension MaterialTextField: FormFieldViewProtocol {}
extension FormFieldViewProtocol where Self: MaterialTextField {
    public func display(valueDescription: String?) {
        debugLog("")
        text = valueDescription
    }

    public func display(validationStatus: ValidationStatus) {
        debugLog("")
    }

    public func display(validationFailures: [ValidationFailure]) {
        debugLog("")
        errorText = validationFailures.first?.explanationMessage
    }

    public func display(title: String) {
        debugLog("")
        self.title = title
    }

    public func display(placeholder: String) {
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

    open override var behaviors: Set<FormFieldBehavior> {
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

    open override var inputAccessoryView: UIView? {
        return _inputAccessoryView
    }

    open override var isEnabled: Bool {
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

    open override var hasValue: Bool {
        return value != nil
    }

    open func textDescription(for value: Value?) -> String? {
        guard let value = value else { return nil }
        return "\(value)"
    }

    open override func outputValueToJSON() -> Any? {
        return value
    }

    public lazy var contentView: ContentView = {
        self.createContentView()
    }()

    open func createContentView() -> ContentView {
        return ContentView()
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
        updateContentView()
        initLifecycle(.programmatically)
    }

    public override init(callInitLifecycle: Bool = true) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func initProperties() {
        super.initProperties()
        title = fieldName
        if usesFieldNameAsPlaceholder { placeholder = fieldName }
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(contentView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        contentView.height.greaterThanOrEqual(to: 0)
        contentView.horizontalEdges.equal(to: horizontalEdges)
        matchContentHeight(of: contentView)
        enforceContentSize()
    }

    open override func setupControlActions() {
        super.setupControlActions()
        addTap { [weak self] _ in
            guard let self = self else { return }
            self.fieldWasTapped()
        }
    }

    open func fieldWasTapped() {
        _ = becomeFirstResponder()
    }

    open func proxyFirstResponder() -> UIResponder? {
        if contentView.canBecomeFirstResponder {
            return contentView
        }
        return nil
    }

    open override func becomeFirstResponder() -> Bool {
        let didRespond = proxyFirstResponder()?.becomeFirstResponder() ?? super.becomeFirstResponder()
        if didRespond {
            validationDelegate?.fieldDidBeginEditing(self)
        }
        return didRespond
    }

    open override var isFirstResponder: Bool {
        return proxyFirstResponder()?.isFirstResponder ?? super.isFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let didResign = proxyFirstResponder()?.resignFirstResponder() ?? super.resignFirstResponder()
        if didResign {
            validationDelegate?.fieldDidEndEditing(self)
        }
        return didResign
    }

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: Validation

    open override func validationStatusChanged(_ status: ValidationStatus) {
        contentView.display(validationStatus: status)
    }

    open override func displayValidationFailures() {
        contentView.display(validationFailures: validationFailures)
    }

    func getValidationErrorMessage() -> String? {
        return validationFailures.first?.explanationMessage
    }

    // MARK: Content View Updating

    open func updateContentView() {
        var fullTitle = title
        for behavior in behaviors {
            switch (behavior, requiresValue) {
            case (.indicatesOptionalFields, false):
                fullTitle += " (optional)"
            case (.indicatesRequiredFields, true):
                fullTitle += " *"
            default: break
            }
        }
        contentView.display(title: fullTitle)
        contentView.display(placeholder: placeholder)
        contentView.display(valueDescription: textDescription(for: value))
    }
}

extension FormFieldProtocol {
    public func getContentView() -> (UIView & FormFieldViewProtocol)? {
        return (self as? FormFieldContentViewProvider)?.getContentView()
    }
}

extension FormField: FormFieldContentViewProvider {
    public func getContentView() -> UIView & FormFieldViewProtocol {
        return contentView
    }
}
