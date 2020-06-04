//
//  FormTextField.swift
//  Pods
//
//  Created by Brian Strobach on 9/8/17.
//
//

import Actions
import Foundation
import Swiftest
import UIKitMixinable

open class FormTextField<ContentView: UIView, Value: Any>: FormField<ContentView, Value>, FormTextFieldProtocol
    where ContentView: FormFieldViewProtocol {
    open lazy var autocorrectionType: UITextAutocorrectionType = .no
    open lazy var keyboardType: UIKeyboardType = .default

    open var disableUserTextEntry: Bool = false {
        didSet {
            textFieldToValidate().hideCaret()
        }
    }

    open lazy var textField: UITextField = {
        self.textFieldToValidate()
    }()

    open func textFieldToValidate() -> UITextField {
        guard let textField = contentView as? UITextField ?? subviews(ofType: UITextField.self).first else {
            assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
            return UITextField()
        }

        return textField
    }

    override open func proxyFirstResponder() -> UIResponder? {
        return self.textField
    }

//
//    open override func updateContentView() {
//        super.updateContentView()
//        if description != textField.text{
//            self.textField.text = self.textDescription(for: value)
//        }
//    }

    // Begin textfield validation config
    open var validationThrottle: Double? {
        didSet {
            self.setupTextFieldAction()
        }
    }

    open var textFieldDelegates: [UITextFieldDelegate] = []
    open var minCharacterCountLimit: Int = 0
    open var maxCharacterCountLimit: Int = Int.max
    open var parkedText: (prepended: String?, appended: String?)
    open var forbiddenCharacterSet: CharacterSet?
    open var allowedCharacterSet: CharacterSet?

    open var limitsInputToMaxCharacterCount: Bool = true
    open var allowsSpaces: Bool = true
    open var minNumberCount: Int?
    open var minLetterCount: Int?
    open var action: Action?
    // End textfield validation config

    override open func initProperties() {
        super.initProperties()
        self.setupValidationRules()
    }

    override open func didInit(type: InitializationType) {
        super.didInit(type: type)
        self.setupTextField(textField: self.textField)
    }

    open func setupValidationRules() {}

    func resetField() {
        validationStatus = .untested
        self.textField.text = nil
    }

    public var confirmationField: FormTextFieldProtocol? {
        didSet {
            self.confirmationField?.confirmsField = self
        }
    }

    public weak var confirmsField: FormTextFieldProtocol?

    var letterCount: Int {
        let letters = CharacterSet.letters

        var letterCount = 0

        for uni in self.textField.text!.unicodeScalars {
            if letters.contains(UnicodeScalar(uni.value)!) {
                letterCount += 1
            }
        }
        return letterCount
    }

    var numberCount: Int {
        let digits = CharacterSet.decimalDigits

        var digitCount = 0

        for uni in textField.text!.unicodeScalars {
            if digits.contains(UnicodeScalar(uni.value)!) {
                digitCount += 1
            }
        }
        return digitCount
    }

    open func setupTextField(textField: UITextField) {
        textField.delegate = self
        textField.keyboardType = self.keyboardType
        textField.autocorrectionType = self.autocorrectionType
        if let inputView = self.inputView {
            textField.inputView = inputView
        }
        self.setupTextFieldAction()
    }

    open func setupTextFieldAction() {
        self.textField.removeActions(for: .editingChanged)

        guard let throttle = validationThrottle else {
            self.textField.addAction(events: [.editingChanged]) { [weak self] in
                self?.textDidChange()
            }
            return
        }

        self.textField.addAction(events: [.editingChanged]) { [weak self] in
            self?.validationStatus = .testingInProgress
        }

        self.textField.throttle(.editingChanged, interval: throttle) { [weak self] in
            self?.textDidChange()
        }
    }

    // MARK: UITextFieldDelegate methods, forward to delegate or to ValidationGroup's delegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        validationDelegate?.fieldDidBeginEditing(self)
        self.textFieldDelegates.forEach { (delegate) -> Void in
            delegate.textFieldDidBeginEditing?(textField)
        }
        if let prefix = parkedText.prepended, let text = textField.text {
            if !text.hasPrefix(prefix) {
                textField.text = prefix
            }
        }
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var delegateOverride: Bool?
        self.textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textFieldShouldEndEditing?(textField) {
                if override == false {
                    delegateOverride = override
                }
            }
        }

        if delegateOverride != nil, delegateOverride! == false {
            return delegateOverride!
        }

        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        var delegateOverride: Bool?
        self.textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textFieldShouldClear?(textField) {
                if override == false {
                    delegateOverride = override
                }
            }
        }

        if delegateOverride != nil, delegateOverride! == false {
            return delegateOverride!
        }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !self.disableUserTextEntry else { return false }
        var delegateOverride: Bool?
        self.textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
                if override == false {
                    delegateOverride = override
                }
            }
        }
        if delegateOverride != nil, delegateOverride! == false {
            return delegateOverride!
        }

        if let prependedCount = parkedText.prepended?.count, range.location < prependedCount {
            return false
        }
        if range.length <= 0, !self.allowsSpaces, string.isWhitespace { // Allow deleting, don't allow whitespace insertion
            return false
        }

        let prevCharCount = textField.text!.count

        if range.length + range.location > prevCharCount {
            return false
        }

        let prependedCharacterCount = self.parkedText.prepended?.count ?? 0
        let newCharCount = prevCharCount + string.count - range.length - prependedCharacterCount

        if self.limitsInputToMaxCharacterCount, newCharCount > self.maxCharacterCountLimit {
            return false
        }
        return true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var delegateOverride: Bool?
        self.textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textFieldShouldBeginEditing?(textField) {
                delegateOverride = override
            }
        }
        if delegateOverride != nil {
            return delegateOverride!
        }
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var delegateOverride: Bool?
        self.textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textFieldShouldReturn?(textField) {
                delegateOverride = override
            }
        }
        if delegateOverride != nil {
            return delegateOverride!
        }
        return false
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        validationDelegate?.fieldDidEndEditing(self)
        self.textFieldDelegates.forEach { (delegate) -> Void in
            delegate.textFieldDidEndEditing?(textField)
        }
        if validationFrequency == .onDidFinishEditing {
            let shouldDisplayErrors = validationErrorDisplayFrequency.equalToAny(of: .onDidFinishEditing, .onValueChanged)
            validate(displayErrors: shouldDisplayErrors)
        }
    }

    open func textDidChange() {
        // Allow for copy and paste of email which automatically appends space - see https://stackoverflow.com/questions/51252525/ios-textfield-autocomplete-adds-blank-character?rq=1
        if !self.allowsSpaces, self.textField.text?.rangeOfCharacter(from: .whitespacesAndNewlines) != nil {
            self.textField.text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if Value.self is String.Type {
            value = self.textField.text as? Value
        }

        if validationFrequency == .onValueChanged {
            validate(displayErrors: validationErrorDisplayFrequency == .onValueChanged)
        }
    }

    override open func runValidationTests() -> [ValidationFailure] {
        var failures: [ValidationFailure] = super.runValidationTests()
        if requiresValue, self.textField.text?.isEmpty == true {
            let failureType = ValidationFailureType.isBlank
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) must not be blank."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        if let confirmationField = confirmationField,
            confirmationField.textField.text?.isEmpty == false {
            confirmationField.validate(displayErrors: displayErrorOnNextValidation)
        } else if let confirmsField = confirmsField,
            confirmsField.textField.text != textField.text {
            let failureType = ValidationFailureType.confirmationFieldDoesNotMatch
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) and \(confirmsField.fieldName) must match."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        let lengthValidity = self.textLengthValidity()
        switch lengthValidity {
        case .tooLong:
            let failureType = ValidationFailureType.tooManyCharacters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) must be less than \(maxCharacterCountLimit) characters."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        case .tooShort:
            let failureType = ValidationFailureType.tooFewCharacters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) must be at least \(minCharacterCountLimit) characters."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        case .justRight:
            break
        }

        if let illegalChars = illegalCharactersInText(textField.text!) {
            let failureType = ValidationFailureType.containsIllegalCharacters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) cannot contain \(illegalChars)"
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        if let minNumberCount = minNumberCount, textField.text?.count(of: .decimalDigits) ?? 0 < minNumberCount {
            let failureType = ValidationFailureType.tooFewNumbers
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) must have at least \(minNumberCount) numbers."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        if let minLetterCount = minLetterCount, textField.text?.count(of: .letters) ?? 0 < minLetterCount {
            let failureType = ValidationFailureType.tooFewLetters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) must have at least \(minLetterCount) letters."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        return failures
    }

    enum TextLengthStatus {
        case tooLong
        case tooShort
        case justRight
    }

    func textLengthValidity() -> TextLengthStatus {
        return self.textLengthValidity(self.textField.text!.count)
    }

    func textLengthValidity(_ length: Int) -> TextLengthStatus {
        let prependCount = self.parkedText.prepended?.count ?? 0

        if length - prependCount < self.minCharacterCountLimit {
            return .tooShort
        } else if length > self.maxCharacterCountLimit {
            return .tooLong
        }
        return .justRight
    }

    func illegalCharactersInText(_ text: String) -> String? {
        // range will be nil if no letters are found
        if let cForbiddenCharacterSet = forbiddenCharacterSet, let range = text.rangeOfCharacter(from: cForbiddenCharacterSet) {
            return String(text[range])
        }

        if let cAllowedCharacterSet = allowedCharacterSet, let range = text.rangeOfCharacter(from: cAllowedCharacterSet.inverted) {
            return String(text[range])
        }
        return nil
    }
}

extension FormTextField where Value == String {
    func textDidChange() {
        value = self.textField.text
    }
}
