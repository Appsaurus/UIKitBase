//
//  FormFieldProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//

import Foundation
import Swiftest
public protocol FormFieldProtocol: AnyObject {
    var fieldName: String { get set }
    var validationStatus: ValidationStatus { get set }
    var validationDelegate: FieldValidationDelegate? { get set }
    var validationFailures: [ValidationFailure] { get set }
    var validationFrequency: FieldValidationFrequency { get set }
    var validationErrorDisplayFrequency: FieldValidationFrequency { get set }
    func validate(displayErrors: Bool)
    func displayValidationFailures()
    func outputValueToJSON() -> Any?
}

extension FormFieldProtocol {
    func runNetworkValidation(_ success: VoidClosure, failure: VoidClosure) {
        success() // Effectively make network validation optional by faking success when not implemented by adopting class
    }
}

public protocol FormTextFieldProtocol: UITextFieldDelegate {
    var textField: UITextField { get set }
    var confirmationField: FormTextFieldProtocol? { get set }
    var confirmsField: FormTextFieldProtocol? { get set }
    var fieldName: String { get set }
    func validate(displayErrors: Bool)
    func displayValidationFailures()
}
