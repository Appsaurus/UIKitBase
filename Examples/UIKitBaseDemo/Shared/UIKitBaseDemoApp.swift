//
//  UIKitBaseDemoApp.swift
//  Shared
//
//  Created by Brian Strobach on 1/14/22.
//

import SwiftUI

@main
struct UIKitBaseDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//struct AppPreview: PreviewProvider {
//    static var previews: some View {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
