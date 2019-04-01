//
//  CustomTabBarItemView.swift
//  Pods
//
//  Created by Brian Strobach on 4/6/17.
//
//

import Layman
import Swiftest
import UIKitTheme

open class CustomTabBarItemView: BaseButton, ObjectDisplayable {
    public typealias DisplayableObjectType = UITabBarItem

    open var tabBarItem: UITabBarItem

    public required init(tabBarItem: UITabBarItem) {
        self.tabBarItem = tabBarItem
        super.init(frame: .zero)
        display(object: tabBarItem)
    }

    open override func initProperties() {
        super.initProperties()
        buttonLayout = ButtonLayout(layoutType: .centerTitleUnderImage(padding: 4), imageLayoutType: .stretchWidth)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func display(object: UITabBarItem) {
        tabBarItem = object
        var images: [ButtonState: UIImage] = [:]
        images[.normal] =? tabBarItem.image
        images[.selected] =? tabBarItem.selectedImage
        imageMap = images
        titleMap[.any] = tabBarItem.title
        print(titleMap)
    }

    open override func style() {
        super.style()
        let tabBarItemStyle: TabBarItemStyle = .defaultStyle

        styleMap = [.normal: .solid(backgroundColor: .clear, textColor: tabBarItemStyle.normalTextColor),
                    .selected: .solid(backgroundColor: .clear, textColor: tabBarItemStyle.selectedTextColor)]
    }
}
