//
//  UITabBarItem+FontIcons.swift
//  UIKitBase
//
//  Created by Brian Strobach on 3/13/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import UIFontIcons
import UIKitTheme

public extension UITabBarItem {
    convenience init<T: FontIconEnum>(icon: T,
                                      selectedIcon: T? = nil,
                                      style: TabBarItemStyle = .defaultStyle,
                                      title: String,
                                      iconHeight: CGFloat? = nil)
    {
        let sizeConfiguration = FontIconSizeConfiguration(size: CGSize(side: 25))
        let normalIconStyle = FontIconStyle(color: style.normalIconColor)
        let normalImage = UIImage.iconImage(icon, configuration: FontIconConfiguration(style: normalIconStyle, sizeConfig: sizeConfiguration))

        let selectedIconStyle = FontIconStyle(color: style.selectedIconColor)
        let selectedImage = UIImage.iconImage(selectedIcon ?? icon, configuration: FontIconConfiguration(style: selectedIconStyle, sizeConfig: sizeConfiguration))
        self.init(title: title, image: normalImage, selectedImage: selectedImage)
        apply(tabBarItemStyle: style)
    }
}
