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

public protocol SubmissionManaged: SubmitButtonManaged {
    associatedtype Submission
    associatedtype Response
    var onCompletion: ResultClosure<Response>? { get set }
    func createSubmission() throws -> Submission
    func submit(_ submission: Submission, _ resultClosure: @escaping ResultClosure<Response>)
    func submissionDidBegin()
    func submissionDidEnd(with result: Result<Response, Error>)
    func submissionDidSucceed(with response: Response)
    func submissionDidFail(with error: Error)
}

public enum SubmissionError: Error {
    case unableToCreateSubmissionError
}

extension SubmissionManaged where Self: UIViewController {
    public func performSubmission() {
        do {
            submissionDidBegin()
            submit(try createSubmission()) { [weak self] result in
                self?.submissionDidEnd(with: result)
            }
        } catch {
            submissionDidEnd(with: .failure(error))
        }
    }

    public func submissionDidEnd(with result: Result<Response, Error>) {
        submissionDidEnd()
        switch result {
        case let .success(response):
            submissionDidSucceed(with: response)
        case let .failure(error):
            submissionDidFail(with: error)
        }
        onCompletion?(result)
    }

    public func submissionDidBegin() {
        submitButton.state = .activity
        view.endEditing(true)
        view.isUserInteractionEnabled = false
    }

    public func submissionDidEnd() {
        view.isUserInteractionEnabled = true
        updateSubmitButtonState()
    }

    public func submissionDidSucceed(with response: Response) {}
    public func submissionDidFail(with error: Error) {
        showError(error: error)
    }
}

public protocol SubmitButtonManaged: AnyObject, ButtonManaged {
    var submitButton: BaseButton { get set }
    var autoSubmitsValidForm: Bool { get set }
    func didPressSubmitButton()
    func didPressSubmitButtonWhileDisabled()
    func updateSubmitButtonState()
    func userCanSubmit() -> Bool
    func performSubmission()
    func autoSubmitIfAllowed()
}

extension SubmitButtonManaged where Self: UIViewController {
    public func performSubmission() {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    public func didPressSubmitButton() {
        performSubmission()
    }

    public func autoSubmitIfAllowed() {
        if autoSubmitsValidForm {
            performSubmission()
        }
    }

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
        button.activityBehaviors = [.removeTitle,
                                    .showIndicator(style: .gray,
                                                   color: navigationBarStyle?.barItemColor,
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

    public func didPressSubmitButtonWhileDisabled() {}

    public func updateSubmitButtonState() {
        DispatchQueue.main.async {
            self.submitButton.state = self.userCanSubmit() ? .normal : .disabled
        }
    }

    public func userCanSubmit() -> Bool {
        return true
    }
}

import DarkMagic

private extension AssociatedObjectKeys {
    static let submitButton = AssociatedObjectKey<BaseButton>("submitButton")
    static let autoSubmitsValidForm = AssociatedObjectKey<Bool>("autoSubmitsValidForm")
}

public extension SubmitButtonManaged where Self: NSObject {
    var submitButton: BaseButton {
        get {
            return self[.submitButton, BaseButton()]
        }
        set {
            self[.submitButton] = newValue
        }
    }

    var autoSubmitsValidForm: Bool {
        get {
            return self[.autoSubmitsValidForm, false]
        }
        set {
            self[.autoSubmitsValidForm] = newValue
        }
    }
}
