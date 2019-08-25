//
//  AuthController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest
import UIKitExtensions

public protocol AuthView: UIView {
    func authenticationDidBegin()
    func authenticationDidFail(_ error: Error)
    func authenticationDidSucceed()
}

public protocol AuthControllerDelegate: AnyObject {
    func authenticationDidBegin<R, V>(controller: AuthController<R, V>)
    func authenticationDidFail<R, V>(controller: AuthController<R, V>, error: Error)
    func authenticationDidSucceed<R, V>(controller: AuthController<R, V>, successResponse: Any)
    func noExistingAuthenticationSessionFound<R, V>(for controller: AuthController<R, V>)
    func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?)
    func logoutDidSucceed<R, V>(for controller: AuthController<R, V>)
}

public typealias AuthSuccessHandler<R> = (_ response: R) -> Void
open class AuthController<R: Codable, V: UIView>: NSObject where V: AuthView {
    open weak var delegate: AuthControllerDelegate?
    open lazy var authView: V = { self.createDefaultAuthView() }()

    open var onSuccessHandler: AuthSuccessHandler<R>?
    open var onFailureHandler: ErrorClosure?

    open func onSuccess(_ closure: @escaping AuthSuccessHandler<R>) -> Self {
        onSuccessHandler = closure
        return self
    }

    open func onFailure(_ closure: @escaping ErrorClosure) -> Self {
        onFailureHandler = closure
        return self
    }

    open func hasAuthenticated() -> Bool {
        return false
    }

    // MARK: Initialization

    public override init() {
        super.init()
        didInit()
    }

    public init(delegate: AuthControllerDelegate) {
        self.delegate = delegate
        super.init()
        didInit()
    }

    open func didInit() {}

    // MARK: Abstract methods

    open func createDefaultAuthView() -> V {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return V()
    }

    open func authenticate() {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    internal func internalAuthenticate() {
        authenticationWillBegin()
        authenticate()
    }

    open func authenticationWillBegin() {
        delegate?.authenticationDidBegin(controller: self)
    }

    open func authenticate(success: @escaping AuthSuccessHandler<R>, failure: @escaping ErrorClosure) {
        onSuccessHandler = success
        onFailureHandler = failure
        internalAuthenticate()
    }

    open func fail(error: Error?) {
        let error = error ?? AuthenticationError.unknown(message: "An unknown error occurred.")
        delegate?.authenticationDidFail(controller: self, error: error)
        onFailureHandler?(error)
    }

    open func succeed(response: R) {
        onSuccessHandler?(response)
        delegate?.authenticationDidSucceed(controller: self, successResponse: response)
    }

    // MARK: Convenience

    open func setupAuthAction(for button: UIButton) {
        button.addAction { [weak self] in
            self?.internalAuthenticate()
        }
    }
}
