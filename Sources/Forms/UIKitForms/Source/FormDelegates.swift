//
//  FormDelegates.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//

import Foundation
import UIKit

public protocol FieldValidationDelegate: AnyObject {
    func fieldIsValidating(_ field: FormFieldProtocol)
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure])
    func fieldPassedValidation(_ field: FormFieldProtocol)
    func fieldDidBeginEditing(_ field: FormFieldProtocol)
    func fieldDidEndEditing(_ field: FormFieldProtocol)
}

// Default implementations to effectively make delegate methods optional
public extension FieldValidationDelegate {
    func fieldIsValidating(_ field: FormFieldProtocol) {}
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}
    func fieldPassedValidation(_ field: FormFieldProtocol) {}
    func fieldDidBeginEditing(_ field: FormFieldProtocol) {}
    func fieldDidEndEditing(_ field: FormFieldProtocol) {}
}

public protocol FormDelegate: FieldValidationDelegate {
    func formIsValidating(_ form: Form)
    func formFailedValidation(_ form: Form, failures: [ValidationFailure])
    func formPassedValidation(_ form: Form)

    // Forwards all FieldValidationDelegate methods.
    func fieldIsValidating(_ field: FormFieldProtocol)
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure])
    func fieldPassedValidation(_ field: FormFieldProtocol)
}

// Default implementations to effectively make delegate methods optional
public extension FormDelegate {
    func formIsValidating(_ form: Form) {}
    func formFailedValidation(_ form: Form, failures: [ValidationFailure]) {}
    func formPassedValidation(_ form: Form) {}

    func fieldIsValidating(_ field: FormFieldProtocol) {}
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}
    func fieldPassedValidation(_ field: FormFieldProtocol) {}
    func fieldDidBeginEditing(_ field: FormFieldProtocol) {}
    func fieldDidEndEditing(_ field: FormFieldProtocol) {}
}
