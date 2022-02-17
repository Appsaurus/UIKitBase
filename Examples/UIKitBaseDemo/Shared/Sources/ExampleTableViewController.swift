//
//  ViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 04/10/2016.
//  Copyright (c) 2016 Brian Strobach. All rights reserved.
//

import UIKitBase
import Actions
import UserNotifications
//import Permission
import Swiftest
import UIFontIcons
import UIKitMixinable
import UIKitBase
import MaterialIcons

class ExampleTableViewController: NavigationalMenuTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.title = "UIKitBase"
//		addRow(title: "BaseButtons", createDestinationVC: BaseButtonExamplesViewController())


        addRow(title: "Memory Leak test", createDestinationVC: ExamplePagedViewController())
        addRow(title: "BaseScrollviewParentViewController Memory Leak test", createDestinationVC: ExampleBasic())
		addRow(title: "Custom Tab Bar Controller", createDestinationVC: ExampleCustomTabBarController())
		addRow(title: "Dismissable Navigation Controller", createDestinationVC: DismissableNavigationController(dismissableViewController: ExamplePaginatableTableViewController()), presentModally: true)
//        addRow(title: "Forms", createDestinationVC: ExampleFormViewController())
		addRow(title: "Needs Loading Indicator", createDestinationVC: ExampleNeedsLoadingIndicatorTableViewController())
		addRow(title: "Pagination", createDestinationVC: ExamplePaginatableTableViewController())
        addRow(title: "Paging Menu ViewControllers", createDestinationVC: PagingMenuExamplesViewController())
		addRow(title: "ScrollViewHeaders", createDestinationVC: ScrollViewHeaderExamplesViewController())
        addRow(title: "Search", createDestinationVC: ExampleSearchViewController())
        addRow(title: "Mixins", createDestinationVC: ExampleUIViewControllerMixinable())
        addRow(title: "BaseViewController", createDestinationVC: ExampleBaseViewController())
    }

	// We are willing to become first responder to get shake motion
	override var canBecomeFirstResponder: Bool {
		get {
			return true
		}
	}

	// Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
				let center = UNUserNotificationCenter.current()
				let options: UNAuthorizationOptions = [.alert, .sound];
				center.requestAuthorization(options: options) {
					(granted, error) in
					if granted {
						sendDeepLink = true
						DispatchQueue.main.async {
							UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
						}
					}
					else{
						self?.showErrorAlert(error)
					}
				}

			}
		}
	}

	override func createSubviews() {
		super.createSubviews()
		let camButton = UIBarButtonItem.barButtonItemWithFontIcon(MaterialIcons.Camera)
		navigationItem.rightBarButtonItem = camButton
		camButton.target = self
		camButton.action = #selector(showCamera)
	}

	@objc func showCamera(){
//        let permissionViewModel = PermissionViewModel(alertTitle: "Real quick...", message: "We need your permission before you can do that.", dismissButtonTitle: "Maybe later.")
//        PermissionViewController.authorize(permissions: .camera, .microphone, permissionViewModel: permissionViewModel, from: self, success: { [weak self] in
//            guard let `self` = self else { return }
//            self.push(ExamplePermissionAuthorizedViewController())
//        }) { (set) in
//            debugLog("Permissions cancelled.")
//        }
	}
}

extension ExampleTableViewController: DeepLinkHandler{
	typealias RouteType = ExampleDeepLinkEnum

	func deepLinkRoutes() -> [RouteType] {
		return [.exampleDeepLinkWithId]
	}

	func respond(to deepLinkRequest: DeepLinkRequest<RouteType>) {
		let route = deepLinkRequest.link.route
		switch route{
		case .exampleDeepLinkWithId:
            guard let id: String = deepLinkRequest.params["id"] as? String else{
				return
			}
			push(ExampleDeepLinkDestinationViewController(id: id))
		}
	}
}
