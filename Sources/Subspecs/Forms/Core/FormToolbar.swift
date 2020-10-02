//
//  FormToolbar.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 10/18/17.
//

import Layman
import Swiftest
import UIKitTheme

@available(iOS 10.0, *)
open class FeedbackGenerator {
    public static func selectionChanged() {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
    }
}

open class FormToolbarStyle: Style {
    open var viewStyle: ViewStyle?
    open var buttonActiveStyle: TextStyle = .regular(color: .primary)
    open var buttonInactiveStyle: TextStyle = .regular(color: .primaryLight)

    public init(viewStyle: ViewStyle? = nil, buttonActiveStyle: TextStyle? = nil, buttonInactiveStyle: TextStyle? = nil) {
        self.viewStyle =? viewStyle
        self.buttonActiveStyle =? buttonActiveStyle
        self.buttonInactiveStyle =? buttonInactiveStyle
    }
}

open class FormToolbar: BaseToolbar, UIInputViewAudioFeedback {
    /// Direction
    ///
    /// Back/Forward arrow button type.
    ///
    /// - upDown: Back/Forward are "^" "v"
    /// - leftRight: Back/Forward are "<" ">"
    public enum Direction {
        case upDown
        case leftRight
    }

    private class FormItem {
        weak var input: FormInput?
        var previousItem: FormItem?
        weak var previousInput: FormInput?
        var nextItem: FormItem?
        weak var nextInput: FormInput?
    }

    private lazy var backButton: UIBarButtonItem = self.buildBackButton()

    private func buildBackButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonHiddenItem: self.backButtonType, target: self, action: #selector(self.backButtonDidTap))
    }

    private lazy var fixedSpacer: UIBarButtonItem = self.buildFixedSpacer()

    private func buildFixedSpacer() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = self.direction == .upDown ? 8.0 : 20.0
        return item
    }

    private lazy var forwardButton: UIBarButtonItem = self.buildForwardButton()

    private func buildForwardButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonHiddenItem: self.forwardButtonType, target: self, action: #selector(self.forwardButtonDidTap))
    }

    private lazy var flexibleSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    private lazy var doneButton: UIBarButtonItem = self.buildDoneButton()

    private func buildDoneButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: self.doneButtonTitle, style: .plain, target: self, action: #selector(self.doneButtonDidtap(_:)))
    }

    private var formItems: [FormItem] = []

    private var backButtonType: UIBarButtonHiddenItem = .prev
    private var forwardButtonType: UIBarButtonHiddenItem = .next

    open var toolBarStyle = FormToolbarStyle()

    override open func style() {
        super.style()
        self.apply(toolBarStyle: self.toolBarStyle)
    }

    open func apply(toolBarStyle: FormToolbarStyle) {
        self.doneButton.apply(textStyle: toolBarStyle.buttonActiveStyle, for: .normal)
        self.doneButton.apply(textStyle: toolBarStyle.buttonInactiveStyle, for: .disabled)
        self.forwardButton.tintColor = toolBarStyle.buttonActiveStyle.color
        self.backButton.tintColor = toolBarStyle.buttonActiveStyle.color
    }

    /// Back/Forward button arrow direction
    public var direction: Direction = .leftRight {
        didSet {
            switch self.direction {
            case .upDown:
                self.backButtonType = .up
                self.forwardButtonType = .down
            case .leftRight:
                self.backButtonType = .prev
                self.forwardButtonType = .next
            }
            self.backButton = self.buildBackButton()
            self.forwardButton = self.buildForwardButton()
            self.fixedSpacer = self.buildFixedSpacer()
            self.updateBarItems()
        }
    }

    /// Done button's title
    /// Default is `"Done"`.
    public var doneButtonTitle: String = "Done" {
        didSet {
            self.doneButton = self.buildDoneButton()
            self.updateBarItems()
        }
    }

    private var currentFormItem: FormItem? {
        return self.formItems.filter { $0.input?.responder.isFirstResponder ?? false }.first
    }

    /// Get current input.
    public var currentInput: FormInput? {
        return self.currentFormItem?.input
    }

    /// Get previous input.
    public var previousInput: FormInput? {
        var previousValidInput = self.currentFormItem?.previousItem
        while previousValidInput?.input?.responder.canBecomeFirstResponder == false {
            previousValidInput = previousValidInput?.previousItem
        }
        return previousValidInput?.input
    }

    /// Get next input.
    public var nextInput: FormInput? {
        var nextItem = self.currentFormItem?.nextItem
        while nextItem?.input?.responder.canBecomeFirstResponder == false {
            nextItem = nextItem?.nextItem
        }
        return nextItem?.input
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - inputs: An array of FormInput.
    ///   - attachToolbarToInputs: If it is true, automatically add self to `input.inputAccessoryView`.
    ///     default is `true`
    public required convenience init(inputs: [FormInput], attachToolbarToInputs: Bool = true) {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44.0)))

        self.set(inputs: inputs, attachToolbarToInputs: attachToolbarToInputs)

        self.updateBarItems()
        self.update()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set new form inputs to toolbar
    ///
    /// - Parameters:
    ///   - inputs: An array of FormInput.
    ///   - attachToolbarToInputs: If it is true, automatically add self to `input.inputAccessoryView`.
    ///     default is `true`
    public func set(inputs: [FormInput], attachToolbarToInputs: Bool = true) {
        // remove toolbar before releasing
        self.formItems.forEach { $0.input?._inputAccessoryView = nil }

        self.formItems = inputs.map { input in
            let formItem = FormItem()
            formItem.input = input
            return formItem
        }

        do {
            var lastFormItem: FormItem?
            self.formItems.forEach { formItem in
                lastFormItem?.nextInput = formItem.input
                lastFormItem?.nextItem = formItem
                formItem.previousInput = lastFormItem?.input
                formItem.previousItem = lastFormItem
                lastFormItem = formItem
            }
        }

        if attachToolbarToInputs {
            inputs.forEach { $0._inputAccessoryView = self }
        }
    }

    /// Update toolbar's buttons.
    public func update() {
        guard self.currentInput != nil else {
            self.backButton.isEnabled = false
            self.forwardButton.isEnabled = false
            return
        }

        self.backButton.isEnabled = self.previousInput != nil
        self.forwardButton.isEnabled = self.nextInput != nil
    }

    /// Go back to previous input.
    public func goBack() {
        if let currentFormItem = currentFormItem {
            let previousInput = self.previousInput
            currentFormItem.input?.responder.resignFirstResponder()
            previousInput?.responder.becomeFirstResponder()
            UIDevice.current.playInputClick()
            if #available(iOS 10.0, *) {
                FeedbackGenerator.selectionChanged()
            }
        }
        self.update()
    }

    /// Go forward to next input.
    public func goForward() {
        if let currentFormItem = currentFormItem {
            let nextInput = self.nextInput
            currentFormItem.input?.responder.resignFirstResponder()
            nextInput?.responder.becomeFirstResponder()
            UIDevice.current.playInputClick()
            if #available(iOS 10.0, *) {
                FeedbackGenerator.selectionChanged()
            }
        }
        self.update()
    }

    private func updateBarItems() {
        let buttonItems: [UIBarButtonItem] = [backButton, fixedSpacer, forwardButton, flexibleSpacer, doneButton]
        setItems(buttonItems, animated: false)
    }

    @objc open func backButtonDidTap() {
        self.goBack()
    }

    @objc open func forwardButtonDidTap() {
        self.goForward()
    }

    @objc private func doneButtonDidtap(_: UIBarButtonItem) {
        guard self.currentFormItem?.input?.responder.resignFirstResponder() == true else {
            parentViewController?.view.endEditing(true)
            return
        }
    }

    // MARK: UIInputViewAudioFeedback

    open var enableInputClicksWhenVisible: Bool {
        return true
    }
}
