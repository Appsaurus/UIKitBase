//
//  UIImage+SFSymbol.swift
//  
//
//  Created by Brian Strobach on 9/28/22.
//

import SFSafeSymbols
import UIKit

extension UIImage {
    public convenience init(_ symbol: SFSymbol, configuration: UIImage.SymbolConfiguration? = nil) {
        self.init(systemSymbol: symbol, withConfiguration: configuration)            
    }
}
//
//public class SFSymbolStyle{
//    open var color: UIColor
//    open var backgroundColor: UIColor
//    open var borderWidth: CGFloat
//    open var borderColor: UIColor
//
//    public init(color: UIColor = SFSymbolDefaults.color,
//                backgroundColor: UIColor = SFSymbolDefaults.backgroundColor,
//                borderWidth: CGFloat = SFSymbolDefaults.borderWidth,
//                borderColor: UIColor = SFSymbolDefaults.borderColor) {
//        self.color = color
//        self.backgroundColor = backgroundColor
//        self.borderWidth = borderWidth
//        self.borderColor = borderColor
//    }
//}
//
//
//public class SFSymbolDefaults{
//    public static var color: UIColor = .white
//    public static var backgroundColor: UIColor = .clear
//    public static var borderWidth: CGFloat = 0
//    public static var borderColor: UIColor = .clear
//
//    public static var fontSize: CGFloat =  50.0
//}
//
//public class SFSymbolConfiguration{
//    open var style: SFSymbolStyle
//    open var sizeConfig: SFSymbolSizeConfiguration
//    public init(style: SFSymbolStyle = SFSymbolStyle(), sizeConfig: SFSymbolSizeConfiguration = SFSymbolSizeConfiguration()) {
//        self.style = style
//        self.sizeConfig = sizeConfig
//    }
//}
//
//public class SFSymbolSizeConfiguration{
//    open var size: CGSize
//    open var fontSize: CGFloat
//    public init(size: CGSize? = nil, fontSize: CGFloat? = nil) {
//        let fontSize = fontSize ?? size?.height ?? SFSymbolDefaults.fontSize
//        self.fontSize = fontSize
//        self.size = size ?? CGSize(width: fontSize, height: fontSize)
//    }
//}
