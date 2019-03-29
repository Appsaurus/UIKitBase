//
//  FormDelegates.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//

import Foundation
import UIKit

public protocol FieldValidationDelegate: class {
    func fieldIsValidating(_ field: FormFieldProtocol)
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure])
    func fieldPassedValidation(_ field: FormFieldProtocol)
    func fieldDidBeginEditing(_ field: FormFieldProtocol)
    func fieldDidEndEditing(_ field: FormFieldProtocol)
}

//Default implementations to effectively make delegate methods optional
extension FieldValidationDelegate {
    public func fieldIsValidating(_ field: FormFieldProtocol) {}
    public func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}
    public func fieldPassedValidation(_ field: FormFieldProtocol) {}
    public func fieldDidBeginEditing(_ field: FormFieldProtocol) {}
    public func fieldDidEndEditing(_ field: FormFieldProtocol) {}
    
}

public protocol FormDelegate: FieldValidationDelegate {
    func formIsValidating(_ form: Form)
    func formFailedValidation(_ form: Form, failures: [ValidationFailure])
    func formPassedValidation(_ form: Form)
    
    //Forwards all FieldValidationDelegate methods.
    func fieldIsValidating(_ field: FormFieldProtocol)
    func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure])
    func fieldPassedValidation(_ field: FormFieldProtocol)
}

//Default implementations to effectively make delegate methods optional
extension FormDelegate {
    public func formIsValidating(_ form: Form) {}
    public func formFailedValidation(_ form: Form, failures: [ValidationFailure]) {}
    public func formPassedValidation(_ form: Form) {}
    
    public func fieldIsValidating(_ field: FormFieldProtocol) {}
    public func fieldFailedValidation(_ field: FormFieldProtocol, failures: [ValidationFailure]) {}
    public func fieldPassedValidation(_ field: FormFieldProtocol) {}
    public func fieldDidBeginEditing(_ field: FormFieldProtocol) {}
    public func fieldDidEndEditing(_ field: FormFieldProtocol) {}
}
