//
//  Validator.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//
import Swiftest
import UIKitBase

public enum ValidationFailureType {
    case missingRequiredValue
    case containsIllegalCharacters
    case isBlank
    case networkValidationFailed
    case tooFewCharacters
    case tooManyCharacters
    case confirmationFieldDoesNotMatch
    case tooFewNumbers
    case tooFewLetters
    case generic
    case customValidation
}

public enum FieldValidationFrequency {
    case onValueChanged
    case onDidFinishEditing
    case manual
}

public enum FieldValidationErrorDisplayFrequency {
    case onValueChanged
    case onDidFinishEditing
    case manual
}

public struct ValidationFailure {
    public var failureType: ValidationFailureType
    public var explanationMessage: String
    public init(failureType: ValidationFailureType, explanationMessage: String) {
        self.failureType = failureType
        self.explanationMessage = explanationMessage
    }
}

open class AbstractFormField: BaseView, FormFieldProtocol {
    open var isEnabled: Bool = true
    open lazy var fieldName: String = className.stringAfterRemoving(substrings: "Field").camelCaseToWords.trimmed
    open var behaviors: Set<FormFieldBehavior> = []
    open var validationFrequency: FieldValidationFrequency = .onValueChanged
    open var validationErrorDisplayFrequency: FieldValidationFrequency = .onDidFinishEditing
    open var displayErrorOnNextValidation: Bool = false // If you want to validate form once from the start, without showing errors
    open var requiresValue: Bool = false
    open var requiresNetworkValidation: Bool = false
    open weak var validationDelegate: FieldValidationDelegate?
    open func responder() -> UIResponder? {
        return self
    }

    open var hasValue: Bool {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return false
    }

    open var customValidationCheck: (() -> ValidationFailure?)?
    open var customErrorMessages: [ValidationFailureType: String] = [:]

    open var passedNetworkValidation: Bool = false

    open var validationFailures: [ValidationFailure] = []
    open var validationErrorMessages: [String] {
        return validationFailures.compactMap { $0.explanationMessage }
    }

    open var validationStatus: ValidationStatus = .untested {
        didSet {
            switch validationStatus {
            case .untested:
                break
            case .valid:
                self.validationDelegate?.fieldPassedValidation(self)
            case .invalid:
                self.validationDelegate?.fieldFailedValidation(self, failures: self.validationFailures)
            case .testingInProgress:
                self.validationDelegate?.fieldIsValidating(self)
            }

            self.validationStatusChanged(validationStatus)

            guard !validationStatus.equalToAny(of: .untested, .testingInProgress) else {
                return
            }

            guard displayErrorOnNextValidation else {
                displayErrorOnNextValidation = true
                return
            }

            self.displayValidationFailures()
        }
    }

    open func validationStatusChanged(_ status: ValidationStatus) {}

    open func displayValidationFailures() {}

    open func validate(displayErrors: Bool = true) {
        self.displayErrorOnNextValidation = displayErrors
        self.validationFailures.removeAll()

        self.validationFailures.append(contentsOf: self.runValidationTests())

        if self.requiresValue, !self.hasValue {
            let failureType = ValidationFailureType.missingRequiredValue
            let explanationMessage = self.customErrorMessages[failureType] ?? "\(self.fieldName) is required."
            self.validationFailures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
        }
        if let failure = customValidationCheck?() {
            self.validationFailures.append(failure)
        }
        if self.validationFailures.count > 0 {
            self.validationStatus = .invalid
        } else if self.requiresNetworkValidation {
            self.validationStatus = ValidationStatus.testingInProgress
            self.runNetworkValidation({ [weak self] () in
                self?.validationStatus = .valid
            }, failure: { [weak self] () in
                // TODO: Get custom error message from network call
                let failureType = ValidationFailureType.networkValidationFailed
                let explanationMessage = self?.customErrorMessages[failureType] ?? "Network validation failed."
                self?.validationFailures.append(ValidationFailure(failureType: failureType, explanationMessage: explanationMessage))
                self?.validationStatus = .invalid
            })
        } else {
            self.validationStatus = .valid
        }
    }

    open func runValidationTests() -> [ValidationFailure] {
        return []
    }

    open func allValidationFailureErrorMessages() -> String {
        var errorMessagesString = ""
        let allFailures = self.validationFailures
        let failureCount = allFailures.count
        for (index, failure) in allFailures.enumerated() {
            errorMessagesString += failure.explanationMessage
            if index != failureCount - 1 {
                errorMessagesString += "\n"
            }
        }
        return errorMessagesString
    }

    open func outputValueToJSON() -> Any? {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return nil
    }

    open func runNetworkValidation(_ success: VoidClosure, failure: VoidClosure) {
        success() // Effectively make network validation optional by faking success when not implemented by adopting class
    }
}
