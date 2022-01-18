//
//  HeadlineLabel.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKitTheme

public class HeadlineLabel: BaseUILabel {
    public var fontSizeMultiplier: CGFloat = 1.0

    override public func initProperties() {
        super.initProperties()
        wrapWords()
        textAlignment = .center
    }

    override public func style() {
        super.style()
        var font: UIFont = .displayTitle1().withSize(font.pointSize * 1.5)
        if #available(iOS 11.0, *) {
            font = .displayLargeTitle()
        }
        let textStyle = TextStyle(color: .primaryLight, font: font)
            .withFontSize(adjustedByMultiplier: self.fontSizeMultiplier)
            .scaledForDevice()
        apply(textStyle: textStyle)
    }
}
