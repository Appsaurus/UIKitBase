//
//  BaseUIApplicationDelegate.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/22/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Swiftest
import UserNotifications
import UIKitTheme
import UIKitMixinable

public protocol BaseUIApplicationDelegateProtocol:
    AppConfigurable
{}
open class BaseUIApplicationDelegate: MixinableAppDelegate, BaseUIApplicationDelegateProtocol {

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [
            AppConfigurableMixin(self)
        ]
    }

    open var appConfiguration: AppConfiguration {
        return AppConfiguration()
    }

    open var viewControllerConfiguration: ViewControllerConfiguration{
        return ViewControllerConfiguration()
    }

    override public init() {
        super.init()
        configureLoggingLevels()
    }

    //MARK: Methods/Functions
    open func configureLoggingLevels(){
        UIApplication.enableAutolayoutWarningLog(false)
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

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.mainWindow.backgroundColor = .mainWindowBackgroundColor
        return true
    }
}

@available(iOS 10.0, *)
public protocol AppIOManager: UIApplicationDelegate, UNUserNotificationCenterDelegate{
    associatedtype AppNotificationIDType: AppNotificationID

    func application(_ application: UIApplication, didReceiveNotification notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didLaunchFrom notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>)

    // MARK: DeepLinking
    associatedtype DeepLinkRouteType: DeepLinkRoute
    var deepLinker: DeepLinker<DeepLinkRouteType> { get }
    func respond(to deepLinkURLRequest: String)
    func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?
}

@available(iOS 10.0, *)
extension AppIOManager{

    public static func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        guard let notificationManager = (UIApplication.shared.delegate as? MixinableAppDelegate)?.appDelegateMixins.first(AppIOManagerMixin.self) else {
            assertionFailure("Attempted to register remote notifications with a BaseAppNotificationManagerMixin.")
            return
        }
        notificationManager.registerForRemoteNotifications(success: success, failure: failure)
    }

    public func application(_ application: UIApplication, didRecieve baseAppNotification: BaseAppNotification){
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didReceiveNotification: notification)
    }

    public func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for baseAppNotification: BaseAppNotification){
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didRecieve: response, for: notification)
    }


    public func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>){
        //Basic logic assumes you have simple notification that user tapped, and want to handle it with a deep link whether the user launched the app with notification or tapped it while the app is active.
        self.application(application, didLaunchFrom: notification)
    }

    public func application(_ application: UIApplication = UIApplication.shared, didReceiveNotification notification: AppNotification<AppNotificationIDType>){
        switch application.applicationState{
        case .active:
            self.application(application, didRecieveNotificationWhileActive: notification)
        case .inactive, .background: //App was opened via notification
            self.application(application, didLaunchFrom: notification)
        }
    }

    public func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>){
        guard let notificationCenterNotification = notification.notificationCenterNotification else  { return }
        NotificationCenter.default.post(notificationCenterNotification)
    }

    public func application(_ application: UIApplication = UIApplication.shared, didLaunchFrom notification: AppNotification<AppNotificationIDType>){
        if let request = convertNotificationToDeepLinkRequest(notification){
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

    //MARK: DeepLinking

    public var deepLinker: DeepLinker<DeepLinkRouteType>{
        return DeepLinker<DeepLinkRouteType>.shared
    }
    public func respond(to deepLinkURLRequest: String){
        deepLinker.respond(to: deepLinkURLRequest)
    }

    public func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?{
        return nil
    }
}

@available(iOS 10.0, *)
open class AppIOManagerMixin: UNUserNotificationCenterDelegateMixin<AppIOManager> {

    var remoteNotificationRegistrationFailure: ErrorClosure?
    var remoteNotificationRegistrationSuccess: VoidClosure?


    //MARK: Registration
    open func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        let application = UIApplication.shared
        remoteNotificationRegistrationSuccess = success
        remoteNotificationRegistrationFailure = failure

        guard application.delegate === mixable else {
            assertionFailure()
            return
        }

        UNUserNotificationCenter.current().delegate = mixable
        UNUserNotificationCenter.current().requestAuthorization(
            options: unAuthorizationOptions(),
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()

    }

    open  func uiUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    }

    @available(iOS 10.0, *)
    open func unAuthorizationOptions() -> UNAuthorizationOptions {
        return [.alert, .badge, .sound]
    }

    //MARK: Abstract Methods

    /// Hook to implement registering of push notifications with backend
    ///
    /// - Parameter token: the device token to register
    open  func registerDevice(withToken token: String, success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerDevice(withToken: String(deviceToken: deviceToken), success: remoteNotificationRegistrationSuccess, failure: remoteNotificationRegistrationFailure)
    }
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Unifying notification methods
        if let localNotification = launchOptions?[.localNotification] as? UILocalNotification, let userInfo = localNotification.userInfo {
            mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .local))
        } else if let remoteNotification = launchOptions?[.remoteNotification] as? [NSObject : AnyObject] {
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
