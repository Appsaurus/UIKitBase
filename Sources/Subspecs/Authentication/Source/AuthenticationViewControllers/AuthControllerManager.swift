//
//  AuthControllerManager.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import KeychainAccess
import Swiftest

public protocol AuthControllerManagerDelegate: AuthControllerDelegate {
    func didBeginSessionRestore<R, V>(for authController: AuthController<R, V>)
    func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?)
    func logoutDidSucceed<R, V>(for controller: AuthController<R, V>)
    func authenticationDidBegin()
    func authenticationDidFail(error: Error)
    func authenticationDidSucceed(successResponse: Any)
    func logoutDidSucceed()
    func logoutDidFail(error: Error?)
    func beginSignup(success: @escaping (Any) -> Void, failure: @escaping ErrorClosure)
}

open class BaseAuthControllerManager: AuthControllerDelegate {
    public required init(delegate: AuthControllerManagerDelegate) {
        self.delegate = delegate
    }

    public weak var delegate: AuthControllerManagerDelegate?

    // MARK: AuthController specific

    open func noExistingAuthenticationSessionFound<R, V>(for controller: AuthController<R, V>) where V: AuthView {
        delegate?.noExistingAuthenticationSessionFound(for: controller)
    }

    open func authenticationDidBegin<R, V>(controller: AuthController<R, V>) where V: AuthView {
        delegate?.authenticationDidBegin(controller: controller)
        authenticationDidBegin()
    }

    open func authenticationDidFail<R, V>(controller: AuthController<R, V>, error: Error) where V: AuthView {
        delegate?.authenticationDidFail(controller: controller, error: error)
        authenticationDidFail(error: error)
    }

    open func authenticationDidSucceed<R, V>(controller: AuthController<R, V>, successResponse: Any) where V: AuthView {
        delegate?.authenticationDidSucceed(controller: controller, successResponse: successResponse)
        authenticationDidSucceed(successResponse: successResponse)
    }

    open func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?) where V: AuthView {
        delegate?.logoutDidFail(for: controller, with: error)
        logoutDidFail(error: error)
    }

    open func logoutDidSucceed<R, V>(for controller: AuthController<R, V>) where V: AuthView {
        delegate?.logoutDidSucceed(for: controller)
        logoutDidSucceed()
    }

    // MARK: Any AuthController

    open func logoutDidSucceed() {
        delegate?.logoutDidSucceed()
    }

    open func logoutDidFail(error: Error?) {
        delegate?.logoutDidFail(error: error)
    }

    open func authenticationDidBegin() {
        delegate?.authenticationDidBegin()
    }

    open func authenticationDidFail(error: Error) {
        delegate?.authenticationDidFail(error: error)
    }

    open func authenticationDidSucceed(successResponse: Any) {
        delegate?.authenticationDidSucceed(successResponse: successResponse)
    }

    // MARK: Logout

    open func logout() {
        logout(success: logoutDidSucceed, failure: logoutDidFail)
    }

    open func logout(success: @escaping VoidClosure, failure: @escaping OptionalErrorClosure) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    //	open func attemptSessionRestoreForMostRecentAuthController(){
    //		assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    //	}
}

public enum AuthKey: String {
    case credentials
}

public extension Keychain {
    subscript<V: Codable>(key: AuthKey) -> V? {
        get {
            do {
                guard let data = try self.getData(key.rawValue) else { return nil }
                return try JSONDecoder().decode(V.self, from: data)
            } catch {
                return nil
            }
        }
        set {
            let jsonEncoder = JSONEncoder()
            guard let data = newValue else {
                try? remove(key.rawValue)
                return
            }
            try? set(try jsonEncoder.encode(data), key: key.rawValue)
        }
    }

    func save(accountIdentifier: String, password: String) {
        self[accountIdentifier] = password
        setSharedPassword(password, account: accountIdentifier)
    }
}

public protocol KeychainCredentialStoring {
    associatedtype Credential: Codable
    var keychain: Keychain { get }
    func saveCredentialsToKeychain(_ credentials: Credential)
    func getSavedCredentialsFromKeychain() -> Credential?
}

public extension KeychainCredentialStoring {
    var keychain: Keychain {
        return Keychain(service: Bundle.main.bundleIdentifier!).synchronizable(true)
    }

    func saveCredentialsToKeychain(_ credentials: Credential) {
        keychain[.credentials] = credentials
    }

    func removeCredentialsFromKeychain() throws {
        try keychain.remove(AuthKey.credentials.rawValue)
    }

    func getSavedCredentialsFromKeychain() -> Credential? {
        return keychain[.credentials]
    }
}
