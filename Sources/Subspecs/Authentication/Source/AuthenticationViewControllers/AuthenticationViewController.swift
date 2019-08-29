//
//  BaseAuthenticationViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest

@available(iOS 9.0, *)
public enum AuthenticationState: State {
    case authenticating, authenticationFailed, authenticationSucceeded
}

public enum AuthenticationError: Error {
    case unknown(message: String?)

    public var description: String {
        switch self {
        case let .unknown(message):
            return message ?? "An unknown error occurred."
        }
    }
}

public extension Notification.Name {
    static let logoutRequested = Notification.Name("logoutRequested")
}

public enum AuthError: LocalizedError, Equatable {
    case tokenRefreshFailed
    case userCancelled
    case userCancelledSignup
    case unknown(message: String?)

    public var localizedDescription: String {
        switch self {
        case let .unknown(message):
            return message ?? "An unknown error occurred."
        case .tokenRefreshFailed:
            return "Failed to refresh session. Please try again."
        case .userCancelled:
            return "Authorization was cancelled by user."
        case .userCancelledSignup:
            return "Signup was cancelled by user."
        }
    }
}

open class AuthenticationViewControllerConfiguration {
    open lazy var showsSystemAlertsForErrors: Bool = true
    open lazy var automaticallySeguesAfterAuthentication: Bool = true

    // Defaults to best effort for logout since most of the time we are simply clearing push notification tokens
    open lazy var dimissesInitialViewControllerOnLogoutAttempt: Bool = true
}

open class AuthenticationViewController: BaseViewController, AuthControllerDelegate {
    open lazy var config: AuthenticationViewControllerConfiguration = AuthenticationViewControllerConfiguration()

    deinit {}

    // MARK: Notifications

    open override func notificationsToObserve() -> [Notification.Name] {
        return [.logoutRequested]
    }

    open override func didObserve(notification: Notification) {
        switch notification.name {
        case .logoutRequested:
            logout()
        default: break
        }
    }

    // MARK: ViewController lifecycle

    open func setupAuthControllers() {}

    open override func viewDidLoad() {
        setupAuthControllers()
        super.viewDidLoad()
    }

    // MARK: Abstract methods

    open func logout() {
        logout(onCompletion: logoutDidComplete)
    }

    open func logout(onCompletion: @escaping ResultClosure<Any?>) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open func beginSignup(success: @escaping (Any) -> Void, failure: @escaping ErrorClosure) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open func createIntialViewControllerAfterLogin() -> UIViewController {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewController()
    }

    open func showAuthViews(animated: Bool = true) {}

    open func hideAuthViews(animated: Bool = true) {}

    open func startAuthenticationInProgressAnimation() {}

    open func stopAuthenticationInProgressAnimation() {}

    // MARK: AuthControllerDelegate

    open func authenticationDidBegin<A: Authenticator>(authenticator: A) {}

    open func authenticationDidComplete<A: Authenticator>(authenticator: A, with result: Result<A.Result, Error>) {
        switch result {
        case let .success(value):
            authenticationDidSucceed(successResponse: value)
        case let .failure(error):
            authenticationDidFail(error: error)
        }
    }

    open func logoutDidComplete<A: Authenticator>(authenticator: A, with result: Result<Any?, Error>) {
        logoutDidComplete(with: result)
    }

    open func didBeginSessionRestore<A: Authenticator>(for authenticator: A) {}

    open func logoutDidComplete(with result: Result<Any?, Error>) {
        onAnyLogoutAttempt()
    }

    open func authenticationDidBegin() {
        hideAuthViews(animated: true)
        startAuthenticationInProgressAnimation()
        view.endEditing(true)
    }

    open func authenticationDidSucceed(successResponse: Any) {
        stopAuthenticationInProgressAnimation()
        guard config.automaticallySeguesAfterAuthentication else { return }
        presentInitialViewController { [weak self] in
            self?.showAuthViews(animated: false)
        }
    }

    open func authenticationDidFail(error: Error) {
        stopAuthenticationInProgressAnimation()
        showAuthViews(animated: true)

        // For developer use, no reason to necessarily show error message when user cancels.
        let ignorableErrors: [AuthError] = [.userCancelled, .userCancelledSignup]

        if let authError = error as? AuthError, authError.equalToAny(of: ignorableErrors) {
            authenticationWasCancelledByUser(error)
            return
        }
        showAuthentication(error: error)
    }

    open func authenticationWasCancelledByUser(_ error: Error? = nil) {
        stopAuthenticationInProgressAnimation()
        showAuthViews(animated: true)
    }

    open func onAnyLogoutAttempt() {
        guard config.dimissesInitialViewControllerOnLogoutAttempt else { return }
        dimissInitialViewController { [weak self] in
            self?.showAuthViews(animated: true)
        }
    }

    // MARK: Presenting/Dismissing initial ViewControllers

    open func dimissInitialViewController(animated: Bool = true, completion: VoidClosure? = nil) {
        guard let navigationController = navigationController else {
            dismiss(animated: animated, completion: completion)
            return
        }
        navigationController.dismiss(animated: animated, completion: completion)
    }

    open func presentInitialViewController(animated: Bool = true, completion: VoidClosure? = nil) {
        let firstVC = createIntialViewControllerAfterLogin()
        guard let navigationController = navigationController else {
            present(viewController: firstVC, animated: animated, completion: completion)
            return
        }
        navigationController.present(firstVC, animated: animated, completion: {
            navigationController.popToRootViewController(animated: false)
            completion?()
        })
    }

    // MARK: Convenience

    open func showAuthentication(error: Error) {
        showError(error: error)
    }

    open func configure<A: Authenticator>(authenticators: A...) {
        authenticators.forEach { authenticator in
            var authenticator = authenticator
            authenticator.delegate = self
        }
    }

    // Stateful convenience
    public func transition(to state: AuthenticationState, animated: Bool = true, completion: (() -> Void)? = nil) {
        transition(to: state.rawValue, animated: animated, completion: completion)
    }
}
