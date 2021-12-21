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

public enum UneditedSubmissionBehavior {
    case disableSubmit
    case skipSubmit
}

public protocol SubmissionManaged: SubmitButtonManaged {
    associatedtype Submission
    associatedtype Response
    var onCompletion: ResultClosure<Response>? { get set }
    var noEditsBehavior: UneditedSubmissionBehavior? { get set }
    var autoSubmitsValidForm: Bool { get set }
    func createSubmission() throws -> Submission
    func submit(_ submission: Submission, _ resultClosure: @escaping ResultClosure<Response>)
    func submissionDidBegin()
    func submissionDidEnd(with result: Result<Response, Error>)
    func submissionDidSucceed(with response: Response)
    func submissionDidFail(with error: Error)
    func autoSubmitIfAllowed()
    func submissionHasBeenEdited() -> Bool
}

public enum SubmissionError: Error {
    case unableToCreateSubmissionError
    case userCancelled
    case submittedNoEdits
}

public extension SubmissionManaged where Self: UIViewController {
    func performSubmission() {
        let isNoEditSubmission = noEditsBehavior == .skipSubmit && !self.submissionHasBeenEdited()
        if isNoEditSubmission {
            self.submissionDidEnd(with: .failure(SubmissionError.submittedNoEdits))
            return
        }
        do {
            self.submissionDidBegin()
            submit(try createSubmission()) { [weak self] result in
                self?.submissionDidEnd(with: result)
            }
        } catch {
            self.submissionDidEnd(with: .failure(error))
        }
    }

    func submissionDidEnd(with result: Result<Response, Error>) {
        self.submissionDidEnd()
        switch result {
        case let .success(response):
            self.submissionDidSucceed(with: response)
        case let .failure(error):
            self.submissionDidFail(with: error)
        }
        onCompletion?(result)
    }

    func submissionDidBegin() {
        submitButton.state = .activity
        view.endEditing(true)
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }

    func submissionDidEnd() {
        view.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
        updateSubmitButtonState()
    }

    func submissionDidSucceed(with response: Response) {}
    func submissionDidFail(with error: Error) {
        switch error {
        case SubmissionError.submittedNoEdits:
            popOrDismiss()
        // No need to report back to user
        default:
            showError(error: error)
        }
    }

    func autoSubmitIfAllowed() {
        if autoSubmitsValidForm {
            self.performSubmission()
        }
    }

    func userCanSubmit() -> Bool {
        guard noEditsBehavior == .disableSubmit else {
            return true
        }
        return self.submissionHasBeenEdited()
    }

    func submissionHasBeenEdited() -> Bool {
        return true
    }
}

public protocol SubmitButtonManaged: AnyObject, ButtonManaged {
    var submitButton: BaseButton { get set }
    func didPressSubmitButton()
    func didPressSubmitButtonWhileDisabled()
    func updateSubmitButtonState()
    func userCanSubmit() -> Bool
    func performSubmission()
}

public extension SubmitButtonManaged where Self: UIViewController {
    func performSubmission() {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    func didPressSubmitButton() {
        self.performSubmission()
    }

    func didPressSubmitButtonWhileDisabled() {}

    @discardableResult
    func setupSubmitButton(configuration: ManagedButtonConfiguration = ManagedButtonConfiguration()) -> BaseButton {
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
        self.setupSubmitButtonAction(for: button)
        submitButton = button
        return button
    }

    func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton {
        let button = BaseButton(buttonLayout: ButtonLayout(layoutType: .titleCentered, marginInsets: LayoutPadding(5)))
        button.titleMap = [.normal: "Submit"]
        styleManagedButton(button: button, position: configuration.position)
        return button
    }

    func setupSubmitButtonAction(for button: BaseButton) {
        button.buttonTapActionMap = [
            .normal: self.didPressSubmitButton,
            .disabled: self.didPressSubmitButtonWhileDisabled
        ]
    }

    func updateSubmitButtonState() {
        DispatchQueue.main.async {
            self.submitButton.state = self.userCanSubmit() ? .normal : .disabled
        }
    }

    func userCanSubmit() -> Bool {
        return true
    }
}

import DarkMagic

private extension AssociatedObjectKeys {
    static let noEditsBehavior = AssociatedObjectKey<UneditedSubmissionBehavior>("noEditsBehavior")
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
}

public extension SubmissionManaged where Self: NSObject {
    var autoSubmitsValidForm: Bool {
        get {
            return self[.autoSubmitsValidForm, false]
        }
        set {
            self[.autoSubmitsValidForm] = newValue
        }
    }

    var noEditsBehavior: UneditedSubmissionBehavior? {
        get {
            return self[.noEditsBehavior]
        }
        set {
            self[.noEditsBehavior] = newValue
        }
    }
}
