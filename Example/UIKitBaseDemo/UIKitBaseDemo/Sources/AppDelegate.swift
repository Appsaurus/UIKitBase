//
//  AppDelegate.swift
//  UIKitBase
//
//  Created by Brian Strobach on 04/10/2016.
//  Copyright (c) 2016 Brian Strobach. All rights reserved.
//

import UIKitBase
import Swiftest
import IQKeyboardManagerSwift
import UserNotifications
import UIKitTheme
import UIKitBase
import UIKitMixinable
import UIFontLoader
var sendDeepLink: Bool = false

@UIApplicationMain
class AppDelegate: BaseUIApplicationDelegate {

    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + [AppIOManagerMixin(self)]
    }

	static var appsaurusWindow: AppsaurusWindow?{
		return shared?.window as? AppsaurusWindow
	}
	static var shared: AppDelegate?{
		return UIApplication.shared.delegate as? AppDelegate
	}
    override var appConfiguration: AppConfiguration {
        let config = ExampleAppConfiguration()
        config.style.tabBarItem.defaults.selectedIconColor = config.style.colors.text.dark
        config.style.tabBarItem.defaults.selectedTextColor = config.style.colors.text.dark
        return config
    }

    override init() {
        FontLoader.loadAllFonts()
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
	open override func configureLoggingLevels(){
        UIApplication.enableAutolayoutWarningLog(false)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
		deepLinker.registerRoutes()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

	override func applicationWillResignActive(_ application: UIApplication) {
		super.applicationWillResignActive(application)
		if sendDeepLink{
			sendDeepLink = false
			let content = UNMutableNotificationContent()
			content.title = NSString.localizedUserNotificationString(forKey: "Yo!", arguments: nil)
			content.body = NSString.localizedUserNotificationString(forKey: "Did somebody order a deep link?",
																	arguments: nil)
			content.userInfo = [
				"notificationId" : "exampleNotification",
				"id" : 99
			]
			var dateInfo = DateComponents()
			let date = Date()
			dateInfo.day = date.day
			dateInfo.hour = date.hour
			dateInfo.minute = date.minute
			dateInfo.second = date.second + 2

			let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
			// Create the request object.
			let request = UNNotificationRequest(identifier: "Deep Link Trigger", content: content, trigger: trigger)
			// Schedule the request.


			let center = UNUserNotificationCenter.current()
			
			center.add(request) { (error : Error?) in
				if let theError = error {
					debugLog(theError.localizedDescription)
				}
			}
		}
	}
}

public enum ExampleNotificationId: String, AppNotificationID{
	case exampleNotification = "exampleNotification"
}
public enum ExampleDeepLinkEnum: String, DeepLinkRoute{
	case exampleDeepLinkWithId = "/id/:id"
}

extension AppDelegate: AppIOManager {

	public typealias AppNotificationIDType = ExampleNotificationId
	public typealias DeepLinkRouteType = ExampleDeepLinkEnum

	public func application(_ application: UIApplication = UIApplication.shared, didRecieveNotificationWhileActive notification: AppNotification<AppNotificationIDType>){

	}
	open func convertNotificationToDeepLinkRequest(_ notification: AppNotification<AppNotificationIDType>) -> String? {
		let scheme = "UIKitBaseExample:"
		guard let notificationId = notification.notificationIdentifier else { return nil }
        do{
            switch notificationId{
                case .exampleNotification: return "\(scheme)//id/\(try notification.parse(key: "id"))"
            }
        }
        catch{
            UIApplication.topmostViewController?.showErrorAlert(title: "Error", message: "Unable to handle push notification. \(error.localizedDescription)")
            return nil
        }
	}
    func registerDevice(withToken token: String, success: VoidClosure?, failure: ErrorClosure?) {
        print("Do registration for token \(token)")
    }
}

