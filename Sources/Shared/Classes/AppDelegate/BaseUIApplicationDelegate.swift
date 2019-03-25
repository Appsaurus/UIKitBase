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

@available(iOS 10, *)

open class BaseUIApplicationDelegate: MixinableApplicationDelegate {

    open var viewControllerConfiguration: ViewControllerConfiguration{
        return ViewControllerConfiguration()
    }

    open lazy var appConfiguration: AppConfiguration? = AppConfiguration()

    override public init() {
        super.init()

        if let appConfiguration = appConfiguration {
            AppConfigurationManager.shared.apply(configuration: appConfiguration)
        }
        ViewControllerConfiguration.default = viewControllerConfiguration
        configureLoggingLevels()
    }


    //MARK: Methods/Functions
    open func configureLoggingLevels(){
        UIApplication.enableAutolayoutWarningLog(false)
    }

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.mainWindow.backgroundColor = .mainWindowBackgroundColor
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}

public protocol BaseAppNotificationManager: class{
    var remoteNotificationRegistrationFailure: ErrorClosure? { get set }
    var remoteNotificationRegistrationSuccess: VoidClosure? { get set }

    func application(_ application: UIApplication, didRecieve baseAppNotification: BaseAppNotification)

    @available(iOS 10.0, *)
    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for baseAppNotification: BaseAppNotification)
}

extension BaseAppNotificationManager {
    public static func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        (UIApplication.shared.delegate as? BaseAppNotificationManager)?.registerForRemoteNotifications(success: success, failure: failure)
    }

    //MARK: Registration
    public func registerForRemoteNotifications(success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        let application = UIApplication.shared
        remoteNotificationRegistrationSuccess = success
        remoteNotificationRegistrationFailure = failure

        guard application.delegate === self else {
            assertionFailure()
            return
        }

        if #available(iOS 10.0, *) {
            assertIsUNUserNotificationCenterDelegate()
            UNUserNotificationCenter.current().requestAuthorization(
                options: unAuthorizationOptions(),
                completionHandler: {_, _ in })
        } else {
            application.registerUserNotificationSettings(uiUserNotificationSettings())
        }

        application.registerForRemoteNotifications()

    }

    internal func assertIsUNUserNotificationCenterDelegate() {
        if #available(iOS 10.0, *){
            guard let mixableUNUserNotificationDelegate = self as? UNUserNotificationCenterDelegate else {
                assertionFailure("Delegates conforming to AppNotificationManager must also conform to UNUserNotificationCenterDelegate.")
                return
            }
            UNUserNotificationCenter.current().delegate = mixableUNUserNotificationDelegate
        }
    }

    public func uiUserNotificationSettings() -> UIUserNotificationSettings {
        return UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    }

    @available(iOS 10.0, *)
    public func unAuthorizationOptions() -> UNAuthorizationOptions {
        return [.alert, .badge, .sound]
    }

    //MARK: Abstract Methods

    /// Hook to implement registering of push notifications with backend
    ///
    /// - Parameter token: the device token to register
    public func registerDevice(withToken token: String, success: VoidClosure? = nil, failure: ErrorClosure? = nil){
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
    }
}

public protocol AppNotificationManager: BaseAppNotificationManager{
    associatedtype AppNotificationIDType: AppNotificationID

    func application(_ application: UIApplication, didReceiveNotification notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>)
    func application(_ application: UIApplication, didLaunchFrom notification: AppNotification<AppNotificationIDType>)

    @available(iOS 10.0, *)
    func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for notification: AppNotification<AppNotificationIDType>)
}

extension AppNotificationManager{


    public func application(_ application: UIApplication, didRecieve baseAppNotification: BaseAppNotification){
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didReceiveNotification: notification)
    }

    @available(iOS 10.0, *)
    public func application(_ application: UIApplication, didRecieve response: UNNotificationResponse, for baseAppNotification: BaseAppNotification){
        let notification = AppNotification<AppNotificationIDType>(notification: baseAppNotification)
        self.application(application, didRecieve: response, for: notification)
    }


    @available(iOS 10.0, *)
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

    @available(iOS 10, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              willPresent notification: UNNotification,
                                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        application(UIApplication.shared, didRecieve: BaseAppNotification(unNotification: notification))
        guard let options = completionHandlerOptions(for: notification) else { return }
        completionHandler(options)
    }

    @available(iOS 10, *)
    public func completionHandlerOptions(for notification: UNNotification) -> UNNotificationPresentationOptions? {
        return [.alert, .badge, .sound]
    }

    @available(iOS 10, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {


        application(UIApplication.shared, didRecieve: response, for: BaseAppNotification(unNotification: response.notification))
        completionHandler()
    }
}


public class AppNotificationManagerMixin: UIApplicationDelegateMixin<AppNotificationManager> {

    open override func didInit() {
        super.didInit()
        mixable.assertIsUNUserNotificationCenterDelegate()
    }

    open override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        mixable.registerDevice(withToken: String(deviceToken: deviceToken))
    }
    open override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        mixable.application(application, didRecieve: BaseAppNotification(payload: userInfo, origin: .remote))
    }

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

public protocol UserLaunchIntentManager : DeepLinkManager, AppNotificationManager{ //TODO: Support shortcut requests and Universal Links
    func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?
}

public extension UserLaunchIntentManager{

    public func application(_ application: UIApplication = UIApplication.shared, didLaunchFrom notification: AppNotification<AppNotificationIDType>){
        if let request = convertNotificationToDeepLinkRequest(notification){
            respond(to: request)
        }
    }

    public func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String?{
        return nil
    }
}

public protocol DeepLinkManager{
    associatedtype DeepLinkRouteType: DeepLinkRoute
    var deepLinker: DeepLinker<DeepLinkRouteType> { get }
    func respond(to deepLinkURLRequest: String)
}

public extension DeepLinkManager{
    public var deepLinker: DeepLinker<DeepLinkRouteType>{
        return DeepLinker<DeepLinkRouteType>.shared
    }
    public func respond(to deepLinkURLRequest: String){
        deepLinker.respond(to: deepLinkURLRequest)
    }
}


