//
//  ContentView.swift
//  Shared
//
//  Created by Brian Strobach on 1/14/22.
//

import SwiftUI
import UIKitBase


struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    var body: some View {
        MainViewController()
    }
}




struct MainViewController: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: BaseNavigationController, context: Context) {

    }

    func makeUIViewController(context: Context) -> BaseNavigationController {
        return BaseNavigationController(rootViewController: ExampleTableViewController())
    }
}
