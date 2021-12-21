//
//  TextStyle+ScaledForDevice.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKitTheme

public extension TextStyle {
    func scaledForDevice(baselineScreenHeight: CGFloat = 667.0, option: FontScalingOption = .downOnly) -> Self {
        font = font.withSize(font.pointSize.scaledForDevice(baselineScreenHeight: baselineScreenHeight, option: option))
        return self
    }
}
