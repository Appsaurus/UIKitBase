//
//  CodeEntryViewController.swift
//  OpenApiClient
//
//  Created by Brian Strobach on 10/15/17.
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

public protocol CodeFormDelegate: class{
    func processVerification(of code: String, success: @escaping VoidClosure, failure: @escaping ErrorClosure) //For asyncronous processing or validation, optionally override
    func requestCode(success: @escaping VoidClosure, failure: @escaping ErrorClosure) //For cases where you may need rerequest a code, like SMS verification when the text does not arrive
    func codeVerificationViewControllerDidVerifyCode()
}

public extension CodeFormDelegate{
    public func processVerification(of code: String, success: @escaping VoidClosure, failure: @escaping ErrorClosure) { //Make this effectively optional
        success()
    }
    public func requestCode(success: @escaping VoidClosure, failure: @escaping ErrorClosure){
        assertionFailure()
    }
}

public struct CodeFormViewControllerConfiguration {
    public let promptText: String? = "Please enter verification code."
    public let resendText: String? = "Resend code"
    public let style: CodeFormViewControllerStyle = CodeFormViewControllerStyle()
    public let codeInputFieldConfiguration: CodeInputFieldConfiguration = CodeInputFieldConfiguration()
    public init(){}
}

open class CodeFormViewControllerStyle{
	private static var s: AppStyleGuide{
		return App.style
	}

	open lazy var statusBarStyle: UIStatusBarStyle = .lightContent
	open lazy var viewStyle: ViewStyle = ViewStyle(backgroundColor: .primary)
	open lazy var promptLabelStyle: TextStyle = .light(color: .primaryContrast)
	open lazy var submitButtonStyle: ButtonStyle = .solid(backgroundColor: .success, textColor: .primaryContrast, font: .regular())
	open lazy var submitButtonDisabledStyle: ButtonStyle = .solid(textColor: .primaryContrast, font: .regular())
	open lazy var navigationBarStyle: NavigationBarStyle = .primary



	public init(statusBarStyle: UIStatusBarStyle? = nil, navigationBarStyle: NavigationBarStyle? = nil, viewStyle: ViewStyle? = nil, promptLabelStyle: TextStyle? = nil, submitButtonStyle: ButtonStyle? = nil, submitButtonDisabledStyle: ButtonStyle? = nil) {
		self.statusBarStyle =? statusBarStyle
		self.navigationBarStyle =? navigationBarStyle
		self.viewStyle =? viewStyle
		self.promptLabelStyle =? promptLabelStyle
		self.submitButtonStyle =? submitButtonStyle
		self.submitButtonDisabledStyle =? submitButtonDisabledStyle
	}

}

public enum CodeFormViewControllerError: LocalizedError{
	case invalidCode
	case expiredCode
	public var errorDescription: String?{
		switch self{
		case .invalidCode: return "Invalid code. Please check your code and try again."
		case .expiredCode: return "That code has expired. Please request a new code and try again."
		}
	}
}
open class CodeFormViewController: FormTableViewController{
    open var configuration: CodeFormViewControllerConfiguration = CodeFormViewControllerConfiguration()
    open weak var delegate: CodeFormDelegate?
    
    open var codeInputField: CodeInputFormField = CodeInputFormField()

    open override var fieldCellInsets: LayoutPadding{
        return LayoutPadding(horizontal: 50, vertical: 20)
    }
    
    public var defaultNavigationBarStyle: NavigationBarStyle?{
        return configuration.style.navigationBarStyle
    }

    
    open override func style() {
        super.style()
        view.apply(viewStyle: configuration.style.viewStyle)
    }
    
    public required init(delegate: CodeFormDelegate, configuration: CodeFormViewControllerConfiguration? = nil) {
        super.init(callDidInit: false)
        self.delegate = delegate
        self.configuration =? configuration
        didInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override var headerPromptText: String?{
        return configuration.promptText
    }
    
    open override func createForm() -> Form {
        return Form(fields: [codeInputField])
    }
    
    open override func createFormToolbar() -> FormToolbar? { //No toolbar needed for single field
        return nil
    }
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        headerPromptLabel?.textAlignment = .center
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = codeInputField.becomeFirstResponder()
    }    
    
    open override func submit(success: @escaping VoidClosure, failure: @escaping ErrorClosure) {
        guard let delegate = delegate, let code = codeInputField.value else{
            assertionFailure("No delegate or value set.")
            return
        }
        delegate.processVerification(of: code, success: success, failure: failure)
    }

    open override func submissionDidSucceed() {
        submitButton.isHidden = true
        super.submissionDidSucceed()
        delegate?.codeVerificationViewControllerDidVerifyCode()
    }
    open override func submissionDidFail(with error: Error) {
        super.submissionDidFail(with: error)
		showError(error: error)
    }
}
