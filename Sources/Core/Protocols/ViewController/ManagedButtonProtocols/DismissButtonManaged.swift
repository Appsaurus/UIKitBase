//
//  DismissButtonManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation
import UIKit
import UIKitTheme
import UIFontIcons
import Layman

public protocol DismissButtonManaged: ButtonManaged{
    @discardableResult
    func setupDismissButton(configuration: ManagedButtonConfiguration) -> BaseButton
    func willDismissViewController()
    func shouldDismissViewController() -> Bool
}
extension DismissButtonManaged where Self: UIViewController{
    
    
    @discardableResult
    public func setupDismissButton(configuration: ManagedButtonConfiguration = ManagedButtonConfiguration()) -> BaseButton{
        let button = createManagedButton(configuration: configuration)
        setupDismissButtonAction(for: button)
        return button
    }
    
    public func defaultButton(configuration: ManagedButtonConfiguration) -> BaseButton {
        let button = BaseButton()
        switch configuration.position{
        case .floatingFooter:
            button.titleMap = [.normal : "Dismiss"]
            button.buttonLayout = ButtonLayout(layoutType: .titleCentered, marginInsets: LayoutPadding(5))
        default:
            button.buttonLayout = ButtonLayout(layoutType: .imageCentered, marginInsets: LayoutPadding(5))
            let style = App.style.barButtonItemStyle
            button.imageMap = [.normal : UIImage.iconImage(MaterialIcons.Close, color: style.textStyle.color, fontSize: style.textStyle.font.pointSize)]
        }
        styleManagedButton(button: button, position: configuration.position)
        return button
    }
    public func setupDismissButtonAction(for button: BaseButton){
        button.onTap = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            if self.shouldDismissViewController(){
                self.willDismissViewController()
                self.popOrDismiss()
            }
        }
    }
    
    public func willDismissViewController(){
        
    }
    public func shouldDismissViewController() -> Bool{
        return true
    }
}
