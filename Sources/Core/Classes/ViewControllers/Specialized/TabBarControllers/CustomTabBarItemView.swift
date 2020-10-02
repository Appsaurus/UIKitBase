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
        self.display(object: tabBarItem)
    }

    override open func initProperties() {
        super.initProperties()
        buttonLayout = ButtonLayout(layoutType: .centerTitleUnderImage(padding: 4), imageLayoutType: .stretchWidth)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func display(object: UITabBarItem) {
        self.tabBarItem = object
        var images: [ButtonState: UIImage] = [:]
        images[.normal] =? self.tabBarItem.image
        images[.selected] =? self.tabBarItem.selectedImage
        imageMap = images
        titleMap[.any] = self.tabBarItem.title
        print(titleMap)
    }

    override open func style() {
        super.style()
        let tabBarItemStyle: TabBarItemStyle = .defaultStyle

        styleMap = [.normal: .solid(backgroundColor: .clear, textColor: tabBarItemStyle.normalTextColor),
                    .selected: .solid(backgroundColor: .clear, textColor: tabBarItemStyle.selectedTextColor)]
    }
}
