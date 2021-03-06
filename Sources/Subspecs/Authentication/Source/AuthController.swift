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
    func authenticationDidBegin<A: Authenticator>(authenticator: A)
    func authenticationDidComplete<A: Authenticator>(authenticator: A, with result: Result<A.Result, Error>)
    func logoutDidComplete<A: Authenticator>(authenticator: A, with result: Result<Any?, Error>)
}

public protocol Authenticator: AnyObject {
    associatedtype Result
    var delegate: AuthControllerDelegate? { get set }
    func hasAuthenticated() -> Bool
}

public extension Authenticator {
    func authenticationWillBegin() {
        delegate?.authenticationDidBegin(authenticator: self)
    }

    func hasAuthenticated() -> Bool {
        return false
    }
}

public protocol OAuthAuthenticator: Authenticator {
    func getAccessToken(onCompletion: @escaping ResultClosure<String>)
    func authenticate(with accessToken: String, onCompletion: @escaping ResultClosure<Result>)
}

public extension OAuthAuthenticator {
    func _authenticate() {
        authenticationWillBegin()
        self.authenticate(onCompletion: { [weak self] result in
            guard let self = self else { return }
            self.delegate?.authenticationDidComplete(authenticator: self, with: result)
        })
    }

    func authenticate(onCompletion: @escaping ResultClosure<Result>) {
        getAccessToken(onCompletion: { [weak self] result in
            guard let self = self else { return }
            do {
                let token: String = try result.get()
                self.authenticate(with: token, onCompletion: onCompletion)
            } catch {
                onCompletion(.failure(error))
            }
        })
    }
}

public typealias AuthSuccessHandler<R> = (_ response: R) -> Void

// open class AuthController<R: Codable>: NSObject, Authenticator {
//
//    public typealias AuthResult = R
//
//    open weak var delegate: AuthControllerDelegate?
//    open var onCompletionHandler: ResultClosure<R>
/// /    open lazy var authView: V = { self.createDefaultAuthView() }()
//
//
//    open func onCompletion(_ closure: @escaping ResultClosure<R>) -> Self {
//        onCompletionHandler = closure
//        return self
//    }
//    open func hasAuthenticated() -> Bool {
//        return false
//    }
//
//    // MARK: Initialization
//
//    required public init(delegate: AuthControllerDelegate, onCompletionHandler: @escaping ResultClosure<R>) {
//        self.delegate = delegate
//        self.onCompletionHandler = onCompletionHandler
//        super.init()
//        didInit()
//    }
//
//    open func didInit() {}
//
//    open func authenticationWillBegin() {
//        delegate?.authenticationDidBegin(authenticator: self)
//    }
//
//    public func _authenticate() {
//        authenticationWillBegin()
//        authenticate(onCompletion: { [weak self] result in
//            guard let self = self else { return }
//            self.delegate?.authenticationDidComplete(authenticator: self, with: result)
//        })
//    }
//
//    open func authenticate(onCompletion: @escaping ResultClosure<R>) {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//    }
//
//
// }
