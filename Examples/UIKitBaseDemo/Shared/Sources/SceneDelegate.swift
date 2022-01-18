//
//  SceneDelegate.swift
//  UIKitBaseDemo
//
//  Created by Brian Strobach on 1/18/22.
//

import UIKitBase
import SwiftUI
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootView = ContentView()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()

//        self.window = ActivityMonitoringWindow()
//        self.window?.rootViewController = BaseNavigationController(rootViewController: ExampleTableViewController())
//        self.window?.makeKeyAndVisible()
    }
}
