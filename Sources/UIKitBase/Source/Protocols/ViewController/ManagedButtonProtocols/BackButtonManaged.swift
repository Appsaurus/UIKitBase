//
//  BackButtonManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/24/18.
//

import Foundation
import Layman
import UIFontIcons
import UIKit

public protocol BackButtonManaged: ButtonManaged {
    func createBackButton<Icon: FontIconEnum>(icon: Icon,
                                              iconConfiguration: FontIconConfiguration?,
                                              configuration: ManagedButtonConfiguration) -> BaseButton
    func backButtonShouldPopViewController() -> Bool
    func popViewControllerIfAllowed()
    func backButtonWillPopViewController()
    func backButtonDidPopViewController()
}

public extension BackButtonManaged {
    static var defaultButtonConfiguration: ManagedButtonConfiguration {
        return ManagedButtonConfiguration(button: BaseButton(buttonLayout: .init(layoutType: .imageCentered,
                                                                                 marginInsets: LayoutPadding(0))),
        position: .navBarLeading,
        size: CGSize(side: 30))
    }

    @discardableResult
    func createBackButton<Icon: FontIconEnum>(icon: Icon,
                                              iconConfiguration: FontIconConfiguration? = nil,
                                              configuration: ManagedButtonConfiguration = defaultButtonConfiguration) -> BaseButton
    {
        let button = configuration.button ?? defaultButton(configuration: configuration)
        let iconConfiguration = iconConfiguration ?? FontIconConfiguration(sizeConfig: FontIconSizeConfiguration(size: configuration.size))
        button.imageMap[.normal] = UIImage(icon: icon, configuration: iconConfiguration)
        button.onTap = popViewControllerIfAllowed
        return createManagedButton(configuration: configuration)
    }

    func backButtonShouldPopViewController() -> Bool {
        return true
    }

    func backButtonWillPopViewController() {}

    func backButtonDidPopViewController() {}
}

public extension BackButtonManaged where Self: UIViewController {
    func popViewControllerIfAllowed() {
        if self.backButtonShouldPopViewController() {
            self.backButtonWillPopViewController()
            navigationController?.popViewController(animated: true)
            self.backButtonDidPopViewController()
        }
    }
}
