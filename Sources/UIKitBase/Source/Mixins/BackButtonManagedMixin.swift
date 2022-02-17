//
//  BackButtonManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIFontIcons
import UIKitMixinable
import UIKitTheme
import MaterialIcons
open class BackButtonManagedMixin: UIViewControllerMixin<BackButtonManaged & UIViewController> {
    override open func createSubviews() {
        var fontIconConfiguration: FontIconConfiguration?
        if let barItemColor = mixable?.navigationBarStyle?.barItemColor {
            fontIconConfiguration = FontIconConfiguration(style: .init(color: barItemColor))
        }
        mixable?.createBackButton(icon: MaterialIcons.Arrow_Back, iconConfiguration: fontIconConfiguration)
    }
}
