//
//  CodeEntryViewController.swift
//  OpenApiClient
//
//  Created by Brian Strobach on 10/15/17.
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitMixinable
import UIKitTheme

public protocol CodeFormDelegate: AnyObject {
    // For asyncronous processing or validation, optionally override
    func processVerification(of code: String, resultClosure: @escaping ResultClosure<Any?>)
    // For cases where you may need rerequest a code, like SMS verification when the text does not arrive
    func requestCode(resultClosure: @escaping ResultClosure<Any?>)
    func codeVerificationViewControllerDidVerifyCode()
}

public extension CodeFormDelegate {
    func processVerification(of code: String, resultClosure: @escaping ResultClosure<Any?>) { // Make this effectively optional
        resultClosure(.success(nil))
    }

    func requestCode(resultClosure: @escaping ResultClosure<Any?>) {
        assertionFailure()
    }
}

public struct CodeFormViewControllerConfiguration {
    public let promptText: String? = "Please enter verification code."
    public let resendText: String? = "Resend code"
    public let autoSubmitsWhenInputIsValid = true
    public let style: CodeFormViewControllerStyle = CodeFormViewControllerStyle()
    public let codeInputFieldConfiguration: CodeInputFieldConfiguration = CodeInputFieldConfiguration()
    public init() {}
}

open class CodeFormViewControllerStyle {
    private static var s: AppStyleGuide {
        return App.style
    }

    open lazy var statusBarStyle: UIStatusBarStyle = .lightContent
    open lazy var viewStyle: ViewStyle = ViewStyle(backgroundColor: .primary)
    open lazy var promptLabelStyle: TextStyle = .light(color: .primaryContrast)
    open lazy var submitButtonStyle: ButtonStyle = .solid(backgroundColor: .success, textColor: .primaryContrast, font: .regular())
    open lazy var submitButtonDisabledStyle: ButtonStyle = .solid(textColor: .primaryContrast, font: .regular())
    open lazy var navigationBarStyle: NavigationBarStyle = .primary

    public init(statusBarStyle: UIStatusBarStyle? = nil,
                navigationBarStyle: NavigationBarStyle? = nil,
                viewStyle: ViewStyle? = nil,
                promptLabelStyle: TextStyle? = nil,
                submitButtonStyle: ButtonStyle? = nil,
                submitButtonDisabledStyle: ButtonStyle? = nil) {
        self.statusBarStyle =? statusBarStyle
        self.navigationBarStyle =? navigationBarStyle
        self.viewStyle =? viewStyle
        self.promptLabelStyle =? promptLabelStyle
        self.submitButtonStyle =? submitButtonStyle
        self.submitButtonDisabledStyle =? submitButtonDisabledStyle
    }
}

public enum CodeFormViewControllerError: LocalizedError {
    case invalidCode
    case expiredCode
    public var errorDescription: String? {
        switch self {
        case .invalidCode: return "Invalid code. Please check your code and try again."
        case .expiredCode: return "That code has expired. Please request a new code and try again."
        }
    }
}

open class CodeFormViewController: FormTableViewController<String, Any?> {
    open var configuration: CodeFormViewControllerConfiguration = CodeFormViewControllerConfiguration()
    open weak var delegate: CodeFormDelegate?

    open var codeInputField: CodeInputFormField = CodeInputFormField<CodeInputTextField>()

    open override var fieldCellInsets: LayoutPadding {
        return LayoutPadding(horizontal: 50, vertical: 20)
    }

    public var defaultNavigationBarStyle: NavigationBarStyle? {
        return configuration.style.navigationBarStyle
    }

    open override func style() {
        super.style()
        view.apply(viewStyle: configuration.style.viewStyle)
    }

    public required init(delegate: CodeFormDelegate, configuration: CodeFormViewControllerConfiguration? = nil) {
        super.init(callInitLifecycle: false)
        self.delegate = delegate
        self.configuration =? configuration
        initLifecycle(.programmatically)
    }

    open override func didInit(type: InitializationType) {
        super.didInit(type: type)
        autoSubmitsValidForm = configuration.autoSubmitsWhenInputIsValid
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override var headerPromptText: String? {
        return configuration.promptText
    }

    open override func createForm() -> Form {
        return Form(fields: [codeInputField])
    }

    open override func createFormToolbar() -> FormToolbar? { // No toolbar needed for single field
        return nil
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        headerPromptLabel?.textAlignment = .center
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = codeInputField.becomeFirstResponder()
    }

    open override func submit(_ submission: String, _ resultClosure: @escaping (Result<Any?, Error>) -> Void) {
        guard let delegate = delegate, let code = codeInputField.value else {
            assertionFailure("No delegate or value set.")
            return
        }
        delegate.processVerification(of: code, resultClosure: resultClosure)
    }

    open override func submissionDidSucceed(with response: Any?) {
        submitButton.isHidden = true
        super.submissionDidSucceed(with: response)
        delegate?.codeVerificationViewControllerDidVerifyCode()
    }

    open override func submissionDidFail(with error: Error) {
        super.submissionDidFail(with: error)
        showError(error: error)
    }
}
