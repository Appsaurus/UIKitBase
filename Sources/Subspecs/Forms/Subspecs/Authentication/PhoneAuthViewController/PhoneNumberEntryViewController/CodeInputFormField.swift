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

// MARK: Delegate

public protocol CodeInputTextFieldDelegate: AnyObject {
    func codeInputTextFieldDidChange(value: String)
}

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

open class CodeInputTextField: BaseView, FormFieldViewProtocol, UIKeyInput {
    public func display(valueDescription: String?) {}

    public func display(validationStatus: ValidationStatus) {}

    public func display(validationFailures: [ValidationFailure]) {}

    public func display(title: String) {}

    public func display(placeholder: String?) {}

    private var nextTag = 0
    open var characterLabels: [UILabel] = []
    open var stackView: HorizontalStackView = HorizontalStackView()
    open var configuration: CodeInputFieldConfiguration = CodeInputFieldConfiguration()

    open var inputFilled: Bool {
        return value.count == configuration.codeLength
    }

    open var value: String {
        return characterLabels.compactMap { $0.text }.joined()
    }

    open weak var delegate: CodeInputTextFieldDelegate?

    public convenience init(configuration: CodeInputFieldConfiguration? = nil) {
        self.init(callDidInit: false)
        self.configuration =? configuration
        didInitProgramatically()
    }

    open override func didInit() {
        super.didInit()
        keyboardType = .numberPad
    }

    open override func style() {
        super.style()
        let s = configuration.style
        for field in characterLabels {
            field.apply(textFieldStyle: field.text.hasNonEmptyValue ? s.filledTextFieldStyle : s.emptyTextFieldStyle)
        }
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(stackView)
        createCodeTextFields()
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.forceSuperviewToMatchContentSize()
        characterLabels.forEach { tf in
            tf.size.equal(to: 30.0.scaledForDevice())
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        characterLabels.forEach { tf in
            tf.adjustFontSizeToFit(height: CGFloat(30.0).scaledForDevice())
        }
    }

    open func createCodeTextFields() {
        configuration.codeLength.times {
            let label = createCharacterInputTextField()
            label.apply(textFieldStyle: configuration.style.emptyTextFieldStyle)
            characterLabels.append(label)
        }
        stackView.swapArrangedSubviews(for: characterLabels)
    }

    open func createCharacterInputTextField() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }

    public var keyboardAppearance: UIKeyboardAppearance {
        return configuration.style.keyboardAppearance
    }

    open var keyboardType: UIKeyboardType = .numberPad

    // MARK: - UIKeyInput

    open var hasText: Bool {
        return true
    }

    open func insertText(_ text: String) {
        guard let label = firstEmptyInputLabel else { return }
        label.text = text
        label.apply(textFieldStyle: configuration.style.filledTextFieldStyle)
        // Notify delegate
        delegate?.codeInputTextFieldDidChange(value: value)
    }

    open func deleteBackward() {
        guard let label = lastFilledInputLabel else { return }
        label.text = nil
        label.apply(textFieldStyle: configuration.style.emptyTextFieldStyle)
        delegate?.codeInputTextFieldDidChange(value: value)
    }

    open func clear() {
        while nextTag > 1 {
            deleteBackward()
        }
    }

    open var lastFilledInputLabel: UILabel? {
        if let empty = firstEmptyInputLabel, let lastEmptyIndex = characterLabels.index(of: empty) {
            return lastEmptyIndex == 0 ? nil : characterLabels[lastEmptyIndex - 1]
        }
        return characterLabels.last
    }

    open var firstEmptyInputLabel: UILabel? {
        return characterLabels.first(where: { $0.text.isNilOrEmpty })
    }
}

open class CodeInputFormField: FormField<CodeInputTextField, String>, CodeInputTextFieldDelegate {
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        contentView.delegate = self
    }

    open func codeInputTextFieldDidChange(value: String) {
        self.value = value.isEmpty ? nil : value
    }

    override func runValidationTests() -> [ValidationFailure] {
        var failures = super.runValidationTests()
        if !contentView.inputFilled {
            failures.append(ValidationFailure(failureType: .customValidation, explanationMessage: "Code too short."))
        }
        return failures
    }
}
