//
//  CodeInputFormField.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 10/15/17.
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

// MARK: Configuration

public struct CodeInputFieldConfiguration {
    public let codeLength: Int = 6
    public let style = CodeInputTextFieldStyle()
    public init() {}
}

// MARK: Style

open class CodeInputTextFieldStyle: Style {
    open var keyboardAppearance: UIKeyboardAppearance = .dark
    open var emptyTextFieldStyle = TextFieldStyle(textStyle: .regular(color: .primaryContrast),
                                                  viewStyle: .roundedRect(backgroundColor: .clear,
                                                                          borderStyle: BorderStyle(borderColor: .primaryContrast, borderWidth: 2.0)))
    open var filledTextFieldStyle = TextFieldStyle(textStyle: .regular(color: .primary),
                                                   viewStyle: .roundedRect(backgroundColor: .primaryContrast,
                                                                           borderStyle: BorderStyle(borderColor: .clear)))

    public init(keyboardAppearance: UIKeyboardAppearance? = nil,
                emptyTextFieldStyle: TextFieldStyle? = nil,
                filledTextFieldStyle: TextFieldStyle? = nil)
    {
        self.keyboardAppearance =? keyboardAppearance
        self.emptyTextFieldStyle =? emptyTextFieldStyle
        self.filledTextFieldStyle =? filledTextFieldStyle
    }
}

open class CodeInputFormField<ContentView: CodeInputTextField>: FormTextField<ContentView, String> {
    open var configuration = CodeInputFieldConfiguration()

    open var inputFilled: Bool {
        return value?.count == self.configuration.codeLength
    }

    public convenience init(configuration: CodeInputFieldConfiguration? = nil) {
        self.init(callInitLifecycle: false)
        self.configuration =? configuration
        initLifecycle(.programmatically)
    }

    override open func initProperties() {
        super.initProperties()
        keyboardType = .numberPad
        textField.keyboardAppearance = self.configuration.style.keyboardAppearance
        textField.textAlignment = .center
        contentView.hideCaret()
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        textField.height.equal(to: 50)
    }

    override open func style() {
        super.style()
        self.updateTextFieldStyle()
    }

    open func updateTextFieldStyle() {
        textField.apply(textFieldStyle: validationStatus == .valid ? self.configuration.style.filledTextFieldStyle : self.configuration.style.emptyTextFieldStyle)
    }

    override open func validationStatusChanged(_ status: ValidationStatus) {
        super.validationStatusChanged(status)
        self.updateTextFieldStyle()
    }

    open func clear() {
        textField.text = nil
    }

    override open func runValidationTests() -> [ValidationFailure] {
        var failures = super.runValidationTests()
        if !self.inputFilled {
            failures.append(ValidationFailure(failureType: .customValidation, explanationMessage: "Code too short."))
        }
        return failures
    }
}

open class CodeInputTextField: BaseTextField, FormFieldViewProtocol {}
