//
//  BaseUIApplicationDelegate.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/22/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Swiftest
import UIKitMixinable
import UIKitTheme
import UserNotifications

public protocol BaseUIApplicationDelegateProtocol: AppConfigurable,
    UNUserNotificationCenterDelegateMixinable {}

@available(iOS 10, *)
open class BaseUIApplicationDelegate: MixinableAppDelegate, BaseUIApplicationDelegateProtocol {
    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [
            AppConfigurableMixin(self)
        ]
    }

    open lazy var userNotificationMixins: [UNUserNotificationCenterDelegateLifeCycle] = self.mixins.compactMap { $0 as? UNUserNotificationCenterDelegateLifeCycle }

    open var appConfiguration: AppConfiguration {
        return AppConfiguration()
    }

    open var viewControllerConfiguration: ViewControllerConfiguration {
        return ViewControllerConfiguration()
    }

    public override init() {
        super.init()
        configureLoggingLevels()
    }

    // MARK: Methods/Functions

    open func configureLoggingLevels() {
        UIApplication.enableAutolayoutWarningLog(false)
    }

    // MARK: UNUserNotificationCenterDelegateMixinable (must be implemented inside class since this is objc protocol)

    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        userNotificationMixins.apply({ (mixin, completionHandler) -> Void? in
            mixin.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        }, completionHandler: { [weak self] results in
            guard let self = self else { return }
            completionHandler(results.first ?? self.completionHandlerOptions(for: notification))
        })
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
        userNotificationMixins.apply({ (mixin, completionHandler) -> Void? in
            mixin.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        }, completionHandler: completionHandler)
    }

    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
    @available(iOS 12.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        userNotificationMixins.forEach { $0.userNotificationCenter?(center, openSettingsFor: notification) }
    }
}

public protocol AppConfigurable {
    var appConfiguration: AppConfiguration { get }
    var viewControllerConfiguration: ViewControllerConfiguration { get }
}

open class AppConfigurableMixin: UIApplicationDelegateMixin<UIApplicationDelegate & AppConfigurable> {
    open override func didInit() {
        super.didInit()
        AppConfigurationManager.shared.apply(configuration: mixable.appConfiguration)
        ViewControllerConfiguration.default = mixable.viewControllerConfiguration
    }

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIApplication.mainWindow.backgroundColor = .mainWindowBackgroundColor
        return true
    }
}

@available(iOS 10.0, *)
public protocol AppIOManager: UIApplicationDelegateMixinable, UNUserNotificationCenterDelegate {
    associatedtype AppNotificationIDType: AppNotificationID

    func application(_ application: UIApplication, didReceiveNotification notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didLaunchFrom notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>)

    // MARK: Abstract Methods

    /// Hook to implement registering of push notifications with backend
    ///
    /// - Parameter token: the device token to register
    func registerDevice(withToken token: String, success: VoidClosure?, failure: ErrorClosure?)

    // MARK: DeepLinking

    associatedtype DeepLinkRouteType: DeepLinkRoute
    var deepLinker: DeepLinker<DeepLinkRouteType> { get }
    func respond(to deepLinkURLRequest: String)
    func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?
}

@available(iOS 10.0, *)
extension AppIOManager {
    public func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil) {
        guard let notificationManager = mixins.first(where: { $0 is AppIOManagerMixin }) as? AppIOManagerMixin else {
            assertionFailure("Attempted to register remote notifications without a AppIOManagerMixin.")
            return
        }
        notificationManager.registerForRemoteNotifications(success: success, failure: failure)
    }

    public func application(_ application: UIApplication, didRecieve baseAppNotification: BaseAppNotification) {
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didReceiveNotification: notification)
    }

    public func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for baseAppNotification: BaseAppNotification) {
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didRecieve: response, for: notification)
    }

    public func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>) {
        // Basic logic assumes you have simple notification that user tapped, and want to handle it with a deep link whether the user launched the app with notification or tapped it while the app is active.
        self.application(application, didLaunchFrom: notification)
    }

    public func application(_ application: UIApplication = UIApplication.shared, didReceiveNotification notification: AppNotification<AppNotificationIDType>) {
        switch application.applicationState {
        case .active:
            self.application(application, didRecieveNotificationWhileActive: notification)
        case .inactive, .background: // App was opened via notification
            self.application(application, didLaunchFrom: notification)
        @unknown default:
            break
        }
    }

    public func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>) {
        guard let notificationCenterNotification = notification.notificationCenterNotification else { return }
        NotificationCenter.default.post(notificationCenterNotification)
    }

    public func application(_ application: UIApplication = UIApplication.shared, didLaunchFrom notification: AppNotification<AppNotificationIDType>) {
        if let request = convertNotificationToDeepLinkRequest(notification) {
            respond(to: request)
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        application(UIApplication.shared, didRecieve: BaseAppNotification(unNotification: notification))
        guard let options = completionHandlerOptions(for: notification) else { return }
        completionHandler(options)
    }

    public func completionHandlerOptions(for notification: UNNotification) -> UNNotificationPresentationOptions? {
        return [.alert, .badge, .sound]
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        application(UIApplication.shared, didRecieve: response, for: BaseAppNotification(unNotification: response.notification))
        completionHandler()
    }

    // MARK: DeepLinking

    public var deepLinker: DeepLinker<DeepLinkRouteType> {
        return DeepLinker<DeepLinkRouteType>.shared
    }

    public func respond(to deepLinkURLRequest: String) {
        deepLinker.respond(to: deepLinkURLRequest)
    }

    public func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String? {
        return nil
    }
}

@available(iOS 10.0, *)
open class AppIOManagerMixin: UNUserNotificationCenterDelegateMixin<AppIOManager> {
    open var remoteNotificationRegistrationFailure: ErrorClosure?
    open var remoteNotificationRegistrationSuccess: VoidClosure?

    // MARK: Registration

    open func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil) {
        let application = UIApplication.shared
        remoteNotificationRegistrationSuccess = success
        remoteNotificationRegistrationFailure = failure

        guard application.delegate === mixable else {
            assertionFailure()
            return
        }

        // Set delegate to owning mixable object, which will ultimately call these mixed methods upon delegation from UNUserNotificationCenter.
        UNUserNotificationCenter.current().delegate = mixable
        UNUserNotificationCenter.current().requestAuthorization(
            options: unAuthorizationOptions(),
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }

    open func unAuthorizationOptions() -> UNAuthorizationOptions {
        return [.alert, .badge, .sound]
    }

    open override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              willPresent notification: UNNotification,
                                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        mixable.application(UIApplication.shared, didRecieve: BaseAppNotification(unNotification: notification))
        guard let options = mixable.completionHandlerOptions(for: notification) else { return }
        completionHandler(options)
    }

    open override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              didReceive response: UNNotificationResponse,
                                              withCompletionHandler completionHandler: @escaping () -> Void) {
        mixable.application(UIApplication.shared, didRecieve: response, for: BaseAppNotification(unNotification: response.notification))
        completionHandler()
    }

    open override func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        mixable.registerDevice(withToken: String(deviceToken: deviceToken), success: remoteNotificationRegistrationSuccess, failure: remoteNotificationRegistrationFailure)
    }

    open override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open override func application(_ application: UIApplication,
                                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                   fetchCompletionHandler
                                   completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Unifying notification methods
        if let remoteNotification = launchOptions?[.remoteNotification] as? [NSObject: AnyObject] {
            mixable.application(application, didRecieve: BaseAppNotification(payload: remoteNotification, origin: .remote))
        }
        return true
    }
}

extension String {
    public init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
