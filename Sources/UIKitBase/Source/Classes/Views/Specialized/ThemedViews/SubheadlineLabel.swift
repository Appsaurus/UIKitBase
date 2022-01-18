//
//  SubheadlineLabel.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKitMixinable
import UIKitTheme

public class SubheadlineLabel: BaseUILabel {
    var fontSizeMultiplier: CGFloat = 1.0

    override public func initProperties() {
        super.initProperties()
        wrapWords()
        textAlignment = .center
    }

    override public func style() {
        super.style()
        let textStyle = TextStyle.body(color: .textMedium).withFontSize(adjustedByMultiplier: self.fontSizeMultiplier)
        apply(textStyle: textStyle)
    }
}
