//
//  IdentifierAndPasswordAuthController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import KeychainAccess
import Layman
import Swiftest
import UIKitTheme

open class IdentifierAndPasswordAuthController<R: Codable, V>: AuthController<R, IdentifierAndPasswordAuthView> {
    // MARK: Initialization

    open override func didInit() {
        super.didInit()
        setupAuthAction(for: authView.logInButton)
    }

    open override func createDefaultAuthView() -> IdentifierAndPasswordAuthView {
        let identifierView = IdentifierAndPasswordAuthView(frame: CGRect.zero)
        identifierView.setContentCompressionResistancePriority(.required, for: NSLayoutConstraint.Axis.vertical)
        identifierView.userIdentifierTextField.placeholder = "Email or username"
        return identifierView
    }

    // MARK: Abastract methods

    open func authenticate(identifier: String, password: String, success: @escaping AuthSuccessHandler<R>, failure: @escaping ErrorClosure) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open override func authenticate() {
        guard let email = self.authView.userIdentifierTextField.text, let password = self.authView.passwordTextField.text else {
            return
        }
        authenticate(identifier: email, password: password, success: { successResponse in
            self.succeed(response: successResponse)
        }, failure: { error in
            self.fail(error: error)
        })
    }
}

open class IdentifierAndPasswordAuthView: BaseView, AuthView {
    open var userIdentifierTextField: UITextField = {
        let identifierField: UITextField = IdentifierAndPasswordAuthView.createTextField("Email or phone number")
        identifierField.autocorrectionType = .no
        identifierField.autocapitalizationType = .none
        if #available(iOS 11.0, *) {
            identifierField.textContentType = .username
        }
        return identifierField
    }()

    open var passwordTextField: UITextField = {
        let passwordField = IdentifierAndPasswordAuthView.createTextField("Password")
        passwordField.isSecureTextEntry = true
        if #available(iOS 11.0, *) {
            passwordField.textContentType = .password
        }
        return passwordField
    }()

    open var logInButton: BaseButton = {
        BaseButton(titles: [.normal: "Sign in"])
    }()

    open var textFieldGroupLayoutView: UIView = UIView()

    public static var fontSize: CGFloat = UIFont.labelFontSize
    public static func createTextField(_ placeHolder: String) -> UITextField {
        let textField = UITextField(frame: CGRect.zero)
        textField.borderStyle = UITextField.BorderStyle.none
        textField.fontSize = fontSize
        textField.placeholder = placeHolder
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        return textField
    }

    open override func createSubviews() {
        super.createSubviews()
        textFieldGroupLayoutView.addSubviews([userIdentifierTextField, passwordTextField])
        addSubviews([textFieldGroupLayoutView, logInButton])
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        let fieldLayoutHeight: CGFloat = 90.0

        // TextFieldGroupLayoutView
        let edgeInsets = LayoutPadding(horizontal: 8, vertical: 0)

        textFieldGroupLayoutView.edges.excluding(.bottom).equalToSuperview()
        textFieldGroupLayoutView.height.equal(to: fieldLayoutHeight)

        userIdentifierTextField.edges.excluding(.bottom).equal(to: edgeInsets)

        passwordTextField.edges.excluding(.top).equal(to: edgeInsets)
        passwordTextField.top.equal(to: userIdentifierTextField.bottom)
        passwordTextField.height.equal(to: userIdentifierTextField)

        // Login Button
        logInButton.edges.excluding(.top).equalToSuperview()
        logInButton.top.equal(to: textFieldGroupLayoutView.bottom.plus(8))
        logInButton.height.equal(to: userIdentifierTextField.height.plus(5))

        forceAutolayoutPass()
    }

    open override func style() {
        super.style()
        textFieldGroupLayoutView.cornerRadius = App.layout.roundedCornerRadius
        textFieldGroupLayoutView.backgroundColor = .primaryContrast
        userIdentifierTextField.textColor = .textMedium

        passwordTextField.addBorder(edges: UIRectEdge.top, color: .textMedium, thickness: 1.0)
        passwordTextField.textColor = .textMedium

        logInButton.apply(buttonStyle: ButtonStyle.solid(backgroundColor: UIColor.primaryContrast.withAlphaComponent(0.4),
                                                         textColor: .primaryContrast,
                                                         shape: .roundedRect))
    }

    open func authenticationDidBegin() {}

    open func authenticationDidSucceed() {}

    open func authenticationDidFail(_ error: Error) {}
}
