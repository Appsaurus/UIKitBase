//
//  AuthControllerManager.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import KeychainAccess
import Swiftest
import Foundation

public enum AuthKey: String {
    case credentials
}

public extension Keychain {
    subscript<V: Codable>(key: AuthKey) -> V? {
        get {
            do {
                guard let data = try getData(key.rawValue) else { return nil }
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
        self.keychain[.credentials] = credentials
    }

    func removeCredentialsFromKeychain() throws {
        try self.keychain.remove(AuthKey.credentials.rawValue)
    }

    func getSavedCredentialsFromKeychain() -> Credential? {
        return self.keychain[.credentials]
    }
}
