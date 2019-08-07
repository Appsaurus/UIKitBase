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

open class AuthenticationViewController<ACM: BaseAuthControllerManager>: BaseViewController, AuthControllerManagerDelegate {
    open lazy var config: AuthenticationViewControllerConfiguration = AuthenticationViewControllerConfiguration()
    open lazy var authControllerManager: ACM = ACM(delegate: self)

    open var mainAuthView: UIView?
    open var authButtons: [AuthButton]?

    deinit {}

    // MARK: Notifications

    open override func notificationsToObserve() -> [Notification.Name] {
        return [.logoutRequested]
    }

    open override func didObserve(notification: Notification) {
        switch notification.name {
        case .logoutRequested:
            authControllerManager.logout()
        default: break
        }
    }

    // MARK: ViewController lifecycle

    open func setupAuthControllers() {}

    open override func setupDelegates() {
        super.setupDelegates()
        authControllerManager.delegate = self
    }

    open override func viewDidLoad() {
        setupAuthControllers()
        super.viewDidLoad()
    }

    // MARK: Abstract methods

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

    // MARK: Any AuthController events

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

    open func logoutDidSucceed() {
        onAnyLogoutAttempt()
    }

    open func logoutDidFail(error: Error?) {
        onAnyLogoutAttempt()
    }

    open func onAnyLogoutAttempt() {
        guard config.dimissesInitialViewControllerOnLogoutAttempt else { return }
        dimissInitialViewController { [weak self] in
            self?.showAuthViews(animated: true)
        }
    }

    // MARK: AuthControllerManagerDelegate

    open func didBeginSessionRestore<R, V>(for authController: AuthController<R, V>) where V: UIView, V: AuthView {}

    open func noExistingAuthenticationSessionFound() {}

    open func authenticationDidBegin<R, V>(controller: AuthController<R, V>) where V: UIView, V: AuthView {}

    open func authenticationDidFail<R, V>(controller: AuthController<R, V>, error: Error) where V: UIView, V: AuthView {}

    open func authenticationDidSucceed<R, V>(controller: AuthController<R, V>, successResponse: Any) where V: UIView, V: AuthView {}

    open func noExistingAuthenticationSessionFound<R, V>(for controller: AuthController<R, V>) where V: UIView, V: AuthView {
        showAuthViews()
    }

    open func logoutDidFail<R, V>(for controller: AuthController<R, V>, with error: Error?) where V: UIView, V: AuthView {}

    open func logoutDidSucceed<R, V>(for controller: AuthController<R, V>) where V: UIView, V: AuthView {}

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

    open func configureMainAuthController<R: Any, V>(_ controller: AuthController<R, V>) {
        controller.delegate = authControllerManager
        mainAuthView = controller.authView
    }

    open func configureAuthButtonControllers<R: Any, B: AuthButton, AC: AuthController<R, B>>(_ controllers: AC...) {
        var authButtons: [AuthButton] = []
        controllers.forEach { controller in
            controller.delegate = authControllerManager
            authButtons.append(controller.authView)
        }
        self.authButtons = authButtons
    }

    // Stateful convenience
    public func transition(to state: AuthenticationState, animated: Bool = true, completion: (() -> Void)? = nil) {
        transition(to: state.rawValue, animated: animated, completion: completion)
    }
}
