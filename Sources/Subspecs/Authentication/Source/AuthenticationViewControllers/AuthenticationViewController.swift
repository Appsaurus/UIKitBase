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
    open lazy var config = AuthenticationViewControllerConfiguration()

    deinit {}

    // MARK: Notifications

    override open func notificationsToObserve() -> [Notification.Name] {
        return [.logoutRequested]
    }

    override open func didObserve(notification: Notification) {
        switch notification.name {
        case .logoutRequested:
            self.logout()
        default: break
        }
    }

    // MARK: ViewController lifecycle

    open func setupAuthControllers() {}

    override open func viewDidLoad() {
        self.setupAuthControllers()
        super.viewDidLoad()
    }

    // MARK: Abstract methods

    open func logout() {
        self.logout(onCompletion: self.logoutDidComplete)
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

    open func authenticationDidBegin<A: Authenticator>(authenticator: A) {
        self.authenticationDidBegin()
    }

    open func authenticationDidComplete<A: Authenticator>(authenticator: A, with result: Result<A.Result, Error>) {
        switch result {
        case let .success(value):
            self.authenticationDidSucceed(successResponse: value)
        case let .failure(error):
            self.authenticationDidFail(error: error)
        }
    }

    open func logoutDidComplete<A: Authenticator>(authenticator: A, with result: Result<Any?, Error>) {
        self.logoutDidComplete(with: result)
    }

    open func didBeginSessionRestore<A: Authenticator>(for authenticator: A) {
//        showAuthenticatingState(animated: false)
    }

    open func logoutDidComplete(with result: Result<Any?, Error>) {
        self.onAnyLogoutAttempt()
    }

    open func authenticationDidBegin() {
        self.showAuthenticatingState()
    }

    open func showReadyToAuthenticateState(animated: Bool = true) {
//        DispatchQueue.main.async {
        self.view.isUserInteractionEnabled = true
        self.showAuthViews(animated: animated)
        self.stopAuthenticationInProgressAnimation()
//        }
    }

    open func showSessionRestoreState() {
//        DispatchQueue.main.async {
        self.view.isUserInteractionEnabled = false
        self.hideAuthViews(animated: false)
        self.startAuthenticationInProgressAnimation()
//        }
    }

    open func showAuthenticatingState(animated: Bool = true) {
//        DispatchQueue.main.async {
        self.view.isUserInteractionEnabled = false
        self.startAuthenticationInProgressAnimation()
        self.view.endEditing(true)
//        }
    }

    open func authenticationDidSucceed(successResponse: Any) {
        self.stopAuthenticationInProgressAnimation()
        guard self.config.automaticallySeguesAfterAuthentication else {
            view.isUserInteractionEnabled = true
            return
        }
        self.presentInitialViewController { [weak self] in
            self?.showReadyToAuthenticateState()
            self?.view.isUserInteractionEnabled = true
        }
    }

    open func authenticationDidFail(error: Error) {
        // For developer use, no reason to necessarily show error message when user cancels.
        let ignorableErrors: [AuthError] = [.userCancelled, .userCancelledSignup]
        if let authError = error as? AuthError, authError.equalToAny(of: ignorableErrors) {
            self.authenticationWasCancelledByUser(error)
            return
        }
        self.showAuthentication(error: error)
        self.showReadyToAuthenticateState()
    }

    open func authenticationWasCancelledByUser(_ error: Error? = nil) {
        self.showReadyToAuthenticateState()
    }

    open func onAnyLogoutAttempt() {
        guard self.config.dimissesInitialViewControllerOnLogoutAttempt else { return }
        self.dimissInitialViewController { [weak self] in
            self?.showReadyToAuthenticateState()
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
        let firstVC = self.createIntialViewControllerAfterLogin()
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
//            var authenticator = authenticator
            authenticator.delegate = self
        }
    }

    // Stateful convenience
    public func transition(to state: AuthenticationState, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.transition(to: state.rawValue, animated: animated, completion: completion)
    }
}
