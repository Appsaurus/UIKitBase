//
//  FormFieldProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//

import Foundation
import Swiftest
import UIKitBase
public protocol FormFieldProtocol: AnyObject {
    var fieldName: String { get set }
    var behaviors: Set<FormFieldBehavior> { get set }
    var validationStatus: ValidationStatus { get set }
    var validationDelegate: FieldValidationDelegate? { get set }
    var validationFailures: [ValidationFailure] { get set }
    var validationFrequency: FieldValidationFrequency { get set }
    var validationErrorDisplayFrequency: FieldValidationFrequency { get set }
    func validate(displayErrors: Bool)
    func displayValidationFailures()
    func outputValueToJSON() -> Any?
    func responder() -> UIResponder?
}

public protocol FormTextFieldProtocol: UITextFieldDelegate {
    var textField: UITextField { get set }
    var confirmationField: FormTextFieldProtocol? { get set }
    var confirmsField: FormTextFieldProtocol? { get set }
    var fieldName: String { get set }
    func validate(displayErrors: Bool)
    func displayValidationFailures()
}
