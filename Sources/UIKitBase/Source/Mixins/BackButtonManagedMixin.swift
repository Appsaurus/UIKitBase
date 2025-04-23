//
//  BackButtonManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIFontIcons
import UIKitMixinable
import UIKitTheme

open class BackButtonManagedMixin: UIViewControllerMixin<BackButtonManaged & UIViewController> {
    var symbol: String = "arrow.left"
    var symbolConfiguration: UIImage.Configuration?
    convenience init<Mixable: UIViewController & BackButtonManaged>(symbol: String = "arrow.left", symbolConfiguration: UIImage.SymbolConfiguration? = nil, _ mixable: Mixable) {
        self.init(mixable)
        self.symbol = symbol
        self.symbolConfiguration = symbolConfiguration
        
    }
    override open func createSubviews() {
        var config = symbolConfiguration
        if config == nil {
            let fontSize = mixable?.navigationBarStyle?.titleTextStyle.font.pointSize
            config = UIImage.SymbolConfiguration(pointSize: fontSize ?? App.style.typography.sizes.navigationBarTitle)
        }
        
        if var image = UIImage(systemName: self.symbol, withConfiguration: symbolConfiguration) {
            if let imageColor = mixable?.navigationBarStyle?.barItemColor {
                image = image.withTintColor(imageColor, renderingMode: .alwaysOriginal)
            }
            mixable?.createBackButton(image: image)
        }
    }
}


