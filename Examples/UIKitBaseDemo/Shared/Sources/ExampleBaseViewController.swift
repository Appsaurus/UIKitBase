//
//  ExampleBaseViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 12/4/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitMixinable
import UIKitTheme
import UIKitBase

extension Notification.Name{
    static let exampleNotification = Notification.Name(rawValue: "exampleNotification")
}

public class ExampleBaseViewController: BaseViewController{
    let button = BaseButton(titles: [.any : "Post Notification"],
                            onTap: { NotificationCenter.post(name: .exampleNotification) })
    open override func notificationsToObserve() -> [Notification.Name] {
        return [.exampleNotification]
    }
    
    open override func didObserve(notification: Notification) {
        print(notification.name.rawValue)
    }
    
    public override func createSubviews() {
        super.createSubviews()
        view.addSubview(button)
    }
    
    public override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        button.centerInSuperview()
    }

}
