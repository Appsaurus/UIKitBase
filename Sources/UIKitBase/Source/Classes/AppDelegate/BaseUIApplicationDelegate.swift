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
    override open func createMixins() -> [LifeCycle] {
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

    override public init() {
        super.init()
        self.configureLoggingLevels()
    }

    // MARK: Methods/Functions

    open func configureLoggingLevels() {
        UIApplication.enableAutolayoutWarningLog(false)
    }

    // MARK: UNUserNotificationCenterDelegateMixinable (must be implemented inside class since this is objc protocol)

    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        self.userNotificationMixins.apply({ mixin, completionHandler -> Void? in
            mixin.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        }, completionHandler: { [weak self] results in
            guard let self = self else { return }
            var results = results.reduce(UNNotificationPresentationOptions()) { $0.union($1) }
            if results.isEmpty {
                results = self.completionHandlerOptions(for: notification)
            }
            completionHandler(results)
        })
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void)
    {
        self.userNotificationMixins.apply({ mixin, completionHandler -> Void? in
            mixin.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        }, completionHandler: completionHandler)
    }

    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
    @available(iOS 12.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        self.userNotificationMixins.forEach { $0.userNotificationCenter?(center, openSettingsFor: notification) }
    }
}

public protocol AppConfigurable {
    var appConfiguration: AppConfiguration { get }
    var viewControllerConfiguration: ViewControllerConfiguration { get }
}

open class AppConfigurableMixin: UIApplicationDelegateMixin<UIApplicationDelegate & AppConfigurable> {
    override open func didInit() {
        super.didInit()
        guard let mixable = self.mixable else { return }
        AppConfigurationManager.shared.apply(configuration: mixable.appConfiguration)
        ViewControllerConfiguration.default = mixable.viewControllerConfiguration
    }

    override open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        /// the system automatically relaunches the app into the background if a new event arrives.
        if #available(iOS 13.0, *) {} else {
            UIApplication.mainWindow.backgroundColor = .mainWindowBackgroundColor
        }

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
    func registerDevice(withToken token: String, serviceToken: String?, success: VoidClosure?, failure: ErrorClosure?)

    // MARK: DeepLinking

    associatedtype DeepLinkRouteType: DeepLinkRoute
    var deepLinker: DeepLinker<DeepLinkRouteType> { get }
    func respond(to deepLinkURLRequest: String)
    func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?
}

@available(iOS 10.0, *)
public extension AppIOManager {
    func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil) {
        guard let notificationManager = mixins.first(where: { $0 is AppIOManagerMixin }) as? AppIOManagerMixin else {
            assertionFailure("Attempted to register remote notifications without a AppIOManagerMixin.")
            return
        }
        notificationManager.registerForRemoteNotifications(success: success, failure: failure)
    }

    func application(_ application: UIApplication, didRecieve baseAppNotification: BaseAppNotification) {
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didReceiveNotification: notification)
    }

    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for baseAppNotification: BaseAppNotification) {
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didRecieve: response, for: notification)
    }

    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>) {
        // Basic logic assumes you have simple notification that user tapped, and want to handle it with a deep link whether the user launched the app with notification or tapped it while the app is active.
        self.application(application, didLaunchFrom: notification)
    }

    func application(_ application: UIApplication = UIApplication.shared, didReceiveNotification notification: AppNotification<AppNotificationIDType>) {
        switch application.applicationState {
        case .active:
            self.application(application, didRecieveNotificationWhileActive: notification)
        case .inactive, .background: // App was opened via notification
            self.application(application, didLaunchFrom: notification)
        @unknown default:
            break
        }
    }

    func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>) {
        guard let notificationCenterNotification = notification.notificationCenterNotification else { return }
        NotificationCenter.default.post(notificationCenterNotification)
    }

    func application(_ application: UIApplication = UIApplication.shared, didLaunchFrom notification: AppNotification<AppNotificationIDType>) {
        if let request = convertNotificationToDeepLinkRequest(notification) {
            self.respond(to: request)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        self.application(UIApplication.shared, didRecieve: BaseAppNotification(unNotification: notification))
        guard let options = completionHandlerOptions(for: notification) else { return }
        completionHandler(options)
    }

    func completionHandlerOptions(for notification: UNNotification) -> UNNotificationPresentationOptions? {
        return [.alert, .badge, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        self.application(UIApplication.shared, didRecieve: response, for: BaseAppNotification(unNotification: response.notification))
        completionHandler()
    }

    // MARK: DeepLinking

    var deepLinker: DeepLinker<DeepLinkRouteType> {
        return DeepLinker<DeepLinkRouteType>.shared
    }

    func respond(to deepLinkURLRequest: String) {
        self.deepLinker.route(to: deepLinkURLRequest)
    }

    func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String? {
        return nil
    }
}

public extension UNAuthorizationOptions {
    static var basicAlerts: UNAuthorizationOptions {
        return [.alert, .badge, .sound]
    }

    static var silentNotifications: UNAuthorizationOptions {
        return []
    }
}

@available(iOS 10.0, *)
open class AppIOManagerMixin: UNUserNotificationCenterDelegateMixin<AppIOManager> {
    open var remoteNotificationRegistrationFailure: ErrorClosure?
    open var remoteNotificationRegistrationSuccess: VoidClosure?

    // MARK: Registration

    override open func didInit() {
        super.didInit()
        UNUserNotificationCenter.current().delegate = mixable
    }

    open func registerForRemoteNotifications(options: UNAuthorizationOptions = .basicAlerts, success: VoidClosure? = nil, failure: ErrorClosure? = nil) {
        let application = UIApplication.shared
        self.remoteNotificationRegistrationSuccess = success
        self.remoteNotificationRegistrationFailure = failure

        guard application.delegate === mixable else {
            assertionFailure()
            return
        }

        // Set delegate to owning mixable object, which will ultimately call these mixed methods upon delegation from UNUserNotificationCenter.
        UNUserNotificationCenter.current().requestAuthorization(
            options: options,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }

    override open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              willPresent notification: UNNotification,
                                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        mixable?.application(UIApplication.shared, didRecieve: BaseAppNotification(unNotification: notification))
        guard let options = mixable?.completionHandlerOptions(for: notification) else {
            completionHandler([])
            return
        }
        completionHandler(options)
    }

    override open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              didReceive response: UNNotificationResponse,
                                              withCompletionHandler completionHandler: @escaping () -> Void)
    {
        mixable?.application(UIApplication.shared, didRecieve: response, for: BaseAppNotification(unNotification: response.notification))
        completionHandler()
    }

    override open func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    override open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        mixable?.registerDevice(withToken: String(deviceToken: deviceToken),
                                serviceToken: nil,
                                success: self.remoteNotificationRegistrationSuccess,
                                failure: self.remoteNotificationRegistrationFailure)
    }

    override open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        mixable?.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    override open func application(_ application: UIApplication,
                                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        mixable?.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    override open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Unifying notification methods
        if let remoteNotification = launchOptions?[.remoteNotification] as? [NSObject: AnyObject] {
            mixable?.application(application, didRecieve: BaseAppNotification(payload: remoteNotification, origin: .remote))
        }
        return true
    }
}

public extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}
