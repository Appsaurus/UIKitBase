//
//  Form.swift
//  Pods
//
//  Created by Brian Strobach on 8/13/17.
/// /  Copyright (c) 2017 Appsaurus. All rights reserved.

import Swiftest
import UIKitExtensions

public enum ValidationStatus {
    case untested
    case valid
    case testingInProgress
    case invalid
}

open class Form: NSObject, FieldValidationDelegate, UITextFieldDelegate {
    open weak var formDelegate: FormDelegate?
    open var status: ValidationStatus = .untested {
        didSet {
            switch status {
            case .untested:
                break
            case .testingInProgress:
                self.formDelegate?.formIsValidating(self)
            case .valid:
                self.formDelegate?.formPassedValidation(self)
            case .invalid:
                var allFailures = self.allFailures
                if let customFailure = customValidationCheck?() {
                    allFailures.append(customFailure)
                }
                self.formDelegate?.formFailedValidation(self, failures: allFailures)
            }
        }
    }

    open var fields: [FormFieldProtocol] = []
    open var allFailures: [ValidationFailure] {
        // Combines all validation faiures from each text field into a single array
        //        return textFields.map{$0.validationFailures}.flatMap{$0}

        var failures: [ValidationFailure] = []
        for field in fields {
            for failure in field.validationFailures {
                failures.append(failure)
            }
        }
        return failures

        //        return flatten(textFields.map{$0.validationFailures})
    }

    open var customValidationCheck: (() -> ValidationFailure?)?

    public convenience init(fields: [FormFieldProtocol]?, initialStatus: ValidationStatus = .untested) {
        self.init()
        if let fields = fields {
            self.fields = fields
            var tag = 0
            for field: FormFieldProtocol in fields {
                field.validationDelegate = self
                field.validationStatus = initialStatus
                //                if let textValidator = field.validator as? UITextFieldValidator{
                //                    textValidator.textFieldDelegates.append(self)
                //                }
                if let view = field as? UIView {
                    view.tag = tag
                    tag += 1
                }
            }
        }
        self.status = initialStatus
    }

    open func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {
        self.formDelegate?.fieldFailedValidation(field, failures: failures)
        self.status = .invalid
    }

    open func fieldPassedValidation(_ field: FormFieldProtocol) {
        self.formDelegate?.fieldPassedValidation(field)

        var untestedCount = 0
        for field in self.fields {
            let fieldStatus = field.validationStatus
            switch fieldStatus {
            case .testingInProgress:
                self.status = .testingInProgress
                return
            case .invalid:
                self.status = .invalid
                return
            case .valid:
                break
            case .untested:
                untestedCount += 1
            }
        }

        if untestedCount > 0 {
            self.status = .untested
        } else {
            self.status = self.customValidationCheck?() == nil ? .valid : .invalid
            //            self.formDelegate?.formPassedValidation(self)
        }
    }

    public func fieldDidBeginEditing(_ field: FormFieldProtocol) {
        self.formDelegate?.fieldDidBeginEditing(field)
    }

    public func fieldDidEndEditing(_ field: FormFieldProtocol) {
        self.formDelegate?.fieldDidEndEditing(field)

        switch (field.validationFrequency, field.validationErrorDisplayFrequency) {
        case let (.onDidFinishEditing, freq):
            field.validate(displayErrors: freq.equalToAny(of: .onDidFinishEditing, .onValueChanged))
        case (.onValueChanged, .onDidFinishEditing):
            field.displayValidationFailures()
        default: break
        }
    }

    open func validate(displayErrors: Bool = true) {
        if self.fields.count == 0 {
            if self.customValidationCheck?() != nil {
                self.status = .invalid
            } else {
                self.status = .valid
            }
        } else {
            for field in self.fields {
                field.validate(displayErrors: displayErrors)
            }
        }
    }

    open func fieldIsValidating(_ field: FormFieldProtocol) {
        self.formDelegate?.fieldIsValidating(field)
        self.status = .testingInProgress
    }

    // MARK: UITextFieldDelegate methods, forward to delegate or to ValidationGroup's delegate

    //    public func textFieldDidBeginEditing(_ textField: UITextField) {
    //        formDelegate?.textFieldDidBeginEditing?(textField)
    //    }
    //
    //
    //    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    //        if let override = formDelegate?.textFieldShouldEndEditing?(textField){
    //            return override
    //        }
    //        return true
    //    }
    //    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
    //        if let override = formDelegate?.textFieldShouldClear?(textField){
    //            return override
    //        }
    //        return true
    //    }
    //
    //    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //        if let override = formDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string){
    //            return override
    //        }
    //        return true
    //
    //    }
    //
    //    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    //        if let override = formDelegate?.textFieldShouldBeginEditing?(textField){
    //            return override
    //        }
    //        return true
    //    }
    //
    //
    //    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //
    //        if let override = self.formDelegate?.textFieldShouldReturn?(textField){
    //            return override
    //        }
    //
    //        let nextTag: NSInteger = textField.tag + 1;
    //        // Try to find next responder
    //
    //
    //        for field in fields{
    //            if let taggedField = field as? UIView{
    //                if taggedField.tag == nextTag{
    //                    taggedField.becomeFirstResponder()
    //                    return false
    //                }
    //            }
    //        }
    //        textField.resignFirstResponder()
    //
    //        if let validatableField = textField as? FormFieldProtocol{
    //            validatableField.validator.validate()
    //        }
    //        return false // We do not want UITextField to insert line-breaks.
    //    }
    //
    //
    //    public func textFieldDidEndEditing(_ textField: UITextField) {
    //        formDelegate?.textFieldDidEndEditing?(textField)
    //    }

    func presentFormErrorsAlertView(_ presentingViewController: UIViewController) {
        var errorMessagesString = ""
        let allFailures = self.allFailures
        let failureCount = allFailures.count
        for (index, failure) in allFailures.enumerated() {
            errorMessagesString += failure.explanationMessage
            if index != failureCount - 1 {
                errorMessagesString += "\n"
            }
        }
        presentingViewController.presentAlert(title: "Form invalid",
                                              message: errorMessagesString,
                                              actions: "OK")
    }
}

extension Form {
    var outputValue: [String: Any] {
        var dict: [String: Any] = [:]
        for field in self.fields {
            dict[field.fieldName] = field.outputValueToJSON()
        }
        return dict
    }
}
