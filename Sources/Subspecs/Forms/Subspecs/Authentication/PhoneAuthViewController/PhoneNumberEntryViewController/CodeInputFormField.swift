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
    public let style: CodeInputTextFieldStyle = CodeInputTextFieldStyle()
    public init() {}
}

// MARK: Style

open class CodeInputTextFieldStyle: Style {
    open var keyboardAppearance: UIKeyboardAppearance = .dark
    open var emptyTextFieldStyle: TextFieldStyle = TextFieldStyle(textStyle: .regular(color: .primaryContrast),
                                                                  viewStyle: .roundedRect(backgroundColor: .clear,
                                                                                          borderStyle: BorderStyle(borderColor: .primaryContrast, borderWidth: 2.0)))
    open var filledTextFieldStyle: TextFieldStyle = TextFieldStyle(textStyle: .regular(color: .primary),
                                                                   viewStyle: .roundedRect(backgroundColor: .primaryContrast,
                                                                                           borderStyle: BorderStyle(borderColor: .clear)))

    public init(keyboardAppearance: UIKeyboardAppearance? = nil,
                emptyTextFieldStyle: TextFieldStyle? = nil,
                filledTextFieldStyle: TextFieldStyle? = nil) {
        self.keyboardAppearance =? keyboardAppearance
        self.emptyTextFieldStyle =? emptyTextFieldStyle
        self.filledTextFieldStyle =? filledTextFieldStyle
    }
}

open class CodeInputFormField<ContentView: CodeInputTextField>: FormTextField<ContentView, String> {
    open var configuration: CodeInputFieldConfiguration = CodeInputFieldConfiguration()

    open var inputFilled: Bool {
        return value?.count == configuration.codeLength
    }

    public convenience init(configuration: CodeInputFieldConfiguration? = nil) {
        self.init(callDidInit: false)
        self.configuration =? configuration
        initLifecycle(.programmatically)
    }

    open override func initProperties() {
        super.initProperties()
        keyboardType = .numberPad
        textField.keyboardAppearance = configuration.style.keyboardAppearance
        textField.textAlignment = .center
        contentView.hideCaret()
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        textField.height.equal(to: 50)
    }

    open override func style() {
        super.style()
        updateTextFieldStyle()
    }

    open func updateTextFieldStyle() {
        textField.apply(textFieldStyle: validationStatus == .valid ? configuration.style.filledTextFieldStyle : configuration.style.emptyTextFieldStyle)
    }

    open override func validationStatusChanged(_ status: ValidationStatus) {
        super.validationStatusChanged(status)
        updateTextFieldStyle()
    }

    open func clear() {
        textField.text = nil
    }

    override func runValidationTests() -> [ValidationFailure] {
        var failures = super.runValidationTests()
        if !inputFilled {
            failures.append(ValidationFailure(failureType: .customValidation, explanationMessage: "Code too short."))
        }
        return failures
    }
}

open class CodeInputTextField: BaseTextField, FormFieldViewProtocol {}
