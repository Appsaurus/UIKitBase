//
//  ButtonManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/24/18.
//

import Foundation
import Swiftest
import UIKitTheme

public class ManagedButtonConfiguration: NSObject {
    var button: BaseButton?
    var position: ManagedButtonPosition
    var size: CGSize?

    public init(button: BaseButton? = nil, position: ManagedButtonPosition = .navBarTrailing, size: CGSize? = nil) {
        self.button = button
        self.position = position
        self.size = size
    }
}

public protocol ButtonManaged {
    func createManagedButton(configuration: ManagedButtonConfiguration) -> BaseButton
    func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton
}

public enum ManagedButtonPosition {
    case navBarLeading
    case navBarTrailing
    case floatingFooter
    case custom
}

extension ButtonManaged where Self: UIViewController {
    @discardableResult
    public func createManagedButton(configuration: ManagedButtonConfiguration = ManagedButtonConfiguration()) -> BaseButton {
        let button: BaseButton = configuration.button ?? defaultButton(configuration: configuration)
        layoutManagedButton(button: button, position: configuration.position, size: configuration.size)
        return button
    }

    public func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton {
        let button = BaseButton()
        styleManagedButton(button: button, position: configuration.position)
        return button
    }

    public func styleManagedButton(button: BaseButton, position: ManagedButtonPosition) {
        switch position {
        case .floatingFooter:
            button.styleMap = [.normal: .outlined(borderColor: .primaryContrast, backgroundColor: .primary)]
        case .custom:
            break
        default: // Nav bar
            button.styleMap = [.normal: .barButtonItemStyle]
        }
    }

    internal func layoutManagedButton(button: BaseButton, position: ManagedButtonPosition, size: CGSize? = nil) {
        switch position {
        case .navBarLeading, .navBarTrailing:
            let item: UIBarButtonItem = UIBarButtonItem(customView: button)

            if position == .navBarTrailing {
                button.titleLabel.textAlignment = .right
                navigationItem.rightBarButtonItem = item
            } else {
                button.titleLabel.textAlignment = .left
                navigationItem.leftBarButtonItem = item
            }

            let size = size ?? button.calculateMaxButtonSize()
            item.customView?.frame.size = button.frame.size
            item.width = size.width

            if #available(iOS 11, *) {
                item.customView?.size.equal(to: size)
            }

            navigationController?.navigationBar.forceAutolayoutPass()
        case .floatingFooter:
            let footer = FooterView<BaseButton>(contentView: button)
            add(footerView: footer, height: size?.height)
        case .custom:
            break
        }
    }
}
