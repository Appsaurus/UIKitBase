//
//  DismissButtonManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation
import Layman
import UIFontIcons
import UIKit
import UIKitTheme
import DarkMagic
import UIKitMixinable
import UIKitTheme

public class NavigationBarButtonConfiguration: NSObject {
    public var position: NavigationBarButtonPosition
    public var size: CGSize?
    public var activityIndicatorStyle: UIActivityIndicatorView.Style

    public init(position: NavigationBarButtonPosition = .trailing,
                size: CGSize? = nil,
                activityIndicatorStyle: UIActivityIndicatorView.Style = .white) {
        self.position = position
        self.size = size
        self.activityIndicatorStyle = activityIndicatorStyle
    }
}
public enum NavigationBarButtonPosition {
    case leading
    case trailing
    case title
}

public protocol NavigationBarButtonManaged {
    func setupNavigationBar(button: BaseUIButton, configuration: NavigationBarButtonConfiguration)
}

public extension NavigationBarButtonManaged where Self: UIViewController & NavigationBarStyleable {

    func setupNavigationBar(button: BaseUIButton, configuration: NavigationBarButtonConfiguration) {
        let position = configuration.position
        switch position {
        case .leading, .trailing:
            let item: UIBarButtonItem = UIBarButtonItem(customView: button)

            button.setTitle("Done", for: .normal)
            if let style = navigationBarStyle?.titleTextStyle ?? self.navigationController?.navigationBarStyle?.titleTextStyle {
                button.apply(textStyle: style)
            }
            if position == .trailing {
//                button.titleLabel.textAlignment = .right
                navigationItem.rightBarButtonItem = item
            } else {
//                button.titleLabel.textAlignment = .left
                navigationItem.leftBarButtonItem = item
            }

//            let size = configuration.size ?? button.calculateMaxButtonSize()
//            item.customView?.frame.size = button.frame.size
//            item.width = size.width
//
//            if #available(iOS 11, *) {
//                item.customView?.size.equal(to: size)
//            }
//
//            navigationController?.navigationBar.forceAutolayoutPass()
        case .title:
            self.navigationItem.titleView = button
        }
    }
}
open class DismissButtonManagedMixin: UIViewControllerMixin<DismissButtonManaged & UIViewController> {
    open override func createSubviews() {
        super.createSubviews()
        mixable.setupDismissButton()
    }
}

public protocol DismissButtonManaged: NavigationBarButtonManaged {
    var dismissButton: BaseUIButton { get set }
    var dismissButtonConfiguration: NavigationBarButtonConfiguration { get set }
    mutating func setupDismissButton()
    func willDismissViewController()
    func shouldDismissViewController() -> Bool
}


extension DismissButtonManaged where Self: UIViewController {

    public mutating func setupDismissButton() {
        setupNavigationBar(button: dismissButton, configuration: dismissButtonConfiguration)
        setupDismissButtonAction(for: self.dismissButton)
    }

    public func setupDismissButtonAction(for button: BaseUIButton) {
        button.addAction { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            if self.shouldDismissViewController() {
                self.willDismissViewController()
                self.popOrDismiss()
            }
        }
    }

    public func willDismissViewController() {}

    public func shouldDismissViewController() -> Bool {
        return true
    }
}

private extension AssociatedObjectKeys{
    static let dismissButton = AssociatedObjectKey<BaseUIButton>("dismissButton")
    static let dismissButtonConfiguration = AssociatedObjectKey<NavigationBarButtonConfiguration>("dismissButtonConfiguration")
}

public extension DismissButtonManaged where Self: NSObject{

    public func defaultButton(configuration: NavigationBarButtonConfiguration) -> BaseUIButton {
        let button = BaseUIButton()
        switch configuration.position {
        case .title:
            break
        default:
            break
        }
        return button
    }

    var dismissButtonConfiguration: NavigationBarButtonConfiguration{
        get{
            return self[.dismissButtonConfiguration, NavigationBarButtonConfiguration()]
        }
        set{
            self[.dismissButtonConfiguration] = newValue
        }
    }

    var dismissButton: BaseUIButton{
        get{
            return self[.dismissButton, self.defaultButton(configuration: self.dismissButtonConfiguration)]
        }
        set{
            self[.dismissButton] = newValue
        }
    }
}
