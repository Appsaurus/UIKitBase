//
//  UITabBarItem+FontIcons.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/13/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import UIFontIcons
import UIKitTheme

extension UITabBarItem {
    public static func item<T: FontIconEnum>(withIcon icon: T,
                                             selectedIcon: T? = nil,
                                             style: TabBarItemStyle = .defaultStyle,
                                             title: String,
                                             tabIconHeight: CGFloat? = nil) -> UITabBarItem {
        let sizeConfiguration: FontIconSizeConfiguration = FontIconSizeConfiguration(fontSize: tabIconHeight ?? .icon)

        let normalIconStyle = FontIconStyle(color: style.normalIconColor)
        let normalImage = UIImage.iconImage(icon, configuration: FontIconConfiguration(style: normalIconStyle, sizeConfig: sizeConfiguration))

        let selectedIconStyle = FontIconStyle(color: style.selectedIconColor)
        let selectedImage = UIImage.iconImage(selectedIcon ?? icon, configuration: FontIconConfiguration(style: selectedIconStyle, sizeConfig: sizeConfiguration))
        let item = UITabBarItem(title: title, image: normalImage, selectedImage: selectedImage)
        item.apply(tabBarItemStyle: style)
        return item
    }
}
