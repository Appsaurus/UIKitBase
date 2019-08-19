//
//  SubmitButtonManaged.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import Foundation
import Layman
import Swiftest

public protocol SubmitButtonManaged: AnyObject, ButtonManaged {
    var submitButton: BaseButton { get set }
    func didPressSubmitButton()
    func didPressSubmitButtonWhileDisabled()
    func submit(success: @escaping VoidClosure, failure: @escaping ErrorClosure)
    func submissionDidBegin()
    func submissionDidEnd()
    func submissionDidSucceed()
    func submissionDidFail(with error: Error)
    func updateSubmitButtonState()
    func userCanSubmit() -> Bool
}

extension SubmitButtonManaged where Self: UIViewController {
    @discardableResult
    public func setupSubmitButton(configuration: ManagedButtonConfiguration = ManagedButtonConfiguration()) -> BaseButton {
        let button = createManagedButton(configuration: configuration)
        var activityIndicatoPosition: ActivityIndicatorPosition = .center
        switch configuration.position {
        case .navBarLeading:
            activityIndicatoPosition = .leading
        case .navBarTrailing:
            activityIndicatoPosition = .trailing
        default:
            break
        }
        button.disabledBehaviors = [.dropAlpha(to: 0.5)]
        let navBarTintColor = navigationController?.navigationBar.tintColor
        button.activityBehaviors = [.removeTitle,
                                    .showIndicator(style: .gray,
                                                   color: navBarTintColor,
                                                   at: activityIndicatoPosition)]
        setupSubmitButtonAction(for: button)
        submitButton = button
        return button
    }

    public func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton {
        let button = BaseButton(buttonLayout: ButtonLayout(layoutType: .titleCentered, marginInsets: LayoutPadding(5)))
        button.titleMap = [.normal: "Submit"]
        styleManagedButton(button: button, position: configuration.position)
        return button
    }

    public func setupSubmitButtonAction(for button: BaseButton) {
        button.buttonTapActionMap = [
            .normal: self.didPressSubmitButton,
            .disabled: self.didPressSubmitButtonWhileDisabled
        ]
    }

    public func didPressSubmitButton() {
        performSubmission()
    }

    public func performSubmission() {
        submissionDidBegin()
        submit(success: { [weak self] in
            self?.submissionDidEnd()
            self?.submissionDidSucceed()
        }, failure: { [weak self] error in
            self?.submissionDidEnd()
            self?.submissionDidFail(with: error)
        })
    }

    public func didPressSubmitButtonWhileDisabled() {}

    public func submit(success: @escaping VoidClosure, failure: @escaping ErrorClosure) {
        success() // By default, for synchronous cases where no async "submission" is needed
    }

    public func submissionDidBegin() {
        submitButton.state = .activity
    }

    public func submissionDidEnd() {
        updateSubmitButtonState()
    }

    public func submissionDidSucceed() {}

    public func submissionDidFail(with error: Error) {}

    public func updateSubmitButtonState() {
        DispatchQueue.main.async {
            self.submitButton.state = self.userCanSubmit() ? .normal : .disabled
        }
    }

    public func userCanSubmit() -> Bool {
        return true
    }

    public func autoSubmitsValidForm() -> Bool {
        return false
    }
}

import DarkMagic

private extension AssociatedObjectKeys{
    static let submitButton = AssociatedObjectKey<BaseButton>("submitButton")
}

public extension SubmitButtonManaged where Self: NSObject{

    public var submitButton: BaseButton{
        get{
            return self[.submitButton, BaseButton()]
        }
        set{
            self[.submitButton] = newValue
        }
    }
}
