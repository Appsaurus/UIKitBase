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

open class FormTextField<ContentView: UIView, Value: Any>: FormField<ContentView, Value>, FormTextFieldProtocol where ContentView: FormFieldViewProtocol {
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
        guard let textField = self.contentView as? UITextField ?? self.subviews(ofType: UITextField.self).first else {
            assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
            return UITextField()
        }

        return textField
    }

    open override func proxyFirstResponder() -> UIResponder? {
        return textField
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

    open var limitsInputToMaxCharacterCount: Bool = true
    open var allowsSpaces: Bool = true
    open var minNumberCount: Int?
    open var minLetterCount: Int?
    open var action: Action?
    // End textfield validation config

    open override func didInit() {
        setupValidationRules()
        super.didInit()
        setupTextField(textField: textField)
    }

    open func setupValidationRules() {}

    func resetField() {
        validationStatus = .untested
        textField.text = nil
    }

    public var confirmationField: FormTextFieldProtocol? {
        didSet {
            confirmsField?.confirmsField = self
        }
    }

    public weak var confirmsField: FormTextFieldProtocol?

    var letterCount: Int {
        let letters = CharacterSet.letters

        var letterCount = 0

        for uni in textField.text!.unicodeScalars {
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
        textField.keyboardType = keyboardType
        textField.autocorrectionType = autocorrectionType
        if let inputView = self.inputView {
            textField.inputView = inputView
        }
        setupTextFieldAction()
    }

    open func setupTextFieldAction() {
        textField.removeActions(for: .editingChanged)

        guard let throttle = validationThrottle else {
            textField.addAction(events: [.editingChanged]) { [weak self] in
                self?.textDidChange()
            }
            return
        }

        textField.addAction(events: [.editingChanged]) { [weak self] in
            self?.validationStatus = .testingInProgress
        }

        textField.throttle(.editingChanged, interval: throttle) { [weak self] in
            self?.textDidChange()
        }
    }

    // MARK: UITextFieldDelegate methods, forward to delegate or to ValidationGroup's delegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        validationDelegate?.fieldDidBeginEditing(self)
        textFieldDelegates.forEach { (delegate) -> Void in
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
        textFieldDelegates.forEach { (delegate) -> Void in
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
        textFieldDelegates.forEach { (delegate) -> Void in
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
        guard !disableUserTextEntry else { return false }
        var delegateOverride: Bool?
        textFieldDelegates.forEach { (delegate) -> Void in
            if let override = delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
                if override == false {
                    delegateOverride = override
                }
            }
        }
        if delegateOverride != nil, delegateOverride! == false {
            return delegateOverride!
        }

        if let prependedCount = self.parkedText.prepended?.count, range.location < prependedCount {
            return false
        }
        if !allowsSpaces, string == " " {
            return false
        }

        let prevCharCount = textField.text!.count

        if range.length + range.location > prevCharCount {
            return false
        }

        let prependedCharacterCount = parkedText.prepended?.count ?? 0
        let newCharCount = prevCharCount + string.count - range.length - prependedCharacterCount

        if limitsInputToMaxCharacterCount, newCharCount > maxCharacterCountLimit {
            return false
        }
        return true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var delegateOverride: Bool?
        textFieldDelegates.forEach { (delegate) -> Void in
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
        textFieldDelegates.forEach { (delegate) -> Void in
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
        textFieldDelegates.forEach { (delegate) -> Void in
            delegate.textFieldDidEndEditing?(textField)
        }
        if validationFrequency == .onDidFinishEditing {
            let shouldDisplayErrors = validationErrorDisplayFrequency.equalToAny(of: .onDidFinishEditing, .onValueChanged)
            validate(displayErrors: shouldDisplayErrors)
        }
    }

    func textDidChange() {
        if Value.self is String.Type {
            value = textField.text as? Value
        }
    }

    override func runValidationTests() -> [ValidationFailure] {
        var failures: [ValidationFailure] = super.runValidationTests()
        if requiresValue, textField.text?.isEmpty == true {
            let failureType = ValidationFailureType.isBlank
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field must not be blank."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        confirmsField?.validate(displayErrors: displayErrorOnNextValidation)

        if let confirmationField = confirmationField {
            let confirmationText = confirmationField.textField.text
            if confirmationText != textField.text {
                let failureType = ValidationFailureType.confirmationFieldDoesNotMatch
                let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field and \(confirmationField.fieldName) field must match."
                failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
            }
        }

        let lengthValidity = textLengthValidity()
        switch lengthValidity {
        case .tooLong:
            let failureType = ValidationFailureType.tooManyCharacters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field must be less than \(maxCharacterCountLimit) characters."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        case .tooShort:
            let failureType = ValidationFailureType.tooFewCharacters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field must be at least \(minCharacterCountLimit) characters."
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
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field must have at least \(minNumberCount) numbers."
            failures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }

        if let minLetterCount = minLetterCount, textField.text?.count(of: .letters) ?? 0 < minLetterCount {
            let failureType = ValidationFailureType.tooFewLetters
            let explanationMessage = customErrorMessages[failureType] ?? "\(fieldName) field must have at least \(minLetterCount) letters."
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
        return textLengthValidity(textField.text!.count)
    }

    func textLengthValidity(_ length: Int) -> TextLengthStatus {
        let prependCount = parkedText.prepended?.count ?? 0

        if length - prependCount < minCharacterCountLimit {
            return .tooShort
        } else if length > maxCharacterCountLimit {
            return .tooLong
        }
        return .justRight
    }

    func illegalCharactersInText(_ text: String) -> String? {
        // range will be nil if no letters are found
        if let cForbiddenCharacterSet = forbiddenCharacterSet, let range = text.rangeOfCharacter(from: cForbiddenCharacterSet) {
            return String(text[range])
        }
        return nil
    }
}

extension FormTextField where Value == String {
    func textDidChange() {
        value = textField.text
    }
}
