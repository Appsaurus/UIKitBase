//
//  BackButtonManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import UIFontIcons
import UIKitMixinable
import UIKitTheme
import SFSafeSymbols
open class BackButtonManagedMixin: UIViewControllerMixin<BackButtonManaged & UIViewController> {
    var symbol = SFSymbol.arrowLeft
    var symbolConfiguration: UIImage.Configuration?
    convenience init<Mixable: UIViewController & BackButtonManaged>(symbol: SFSymbol, symbolConfiguration: UIImage.SymbolConfiguration? = nil, _ mixable: Mixable) {
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
        var image = UIImage(systemSymbol: self.symbol, withConfiguration: symbolConfiguration)
        if let imageColor = mixable?.navigationBarStyle?.barItemColor {
            image = image.withTintColor(imageColor, renderingMode: .alwaysOriginal)
        }
        mixable?.createBackButton(image: image)
    }
}


