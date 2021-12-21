//
//  LayoutDimension+AutoExpand.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Layman

public extension LayoutDimension {
    @discardableResult
    func autoExpand(minimum: LayoutConstant = 1.0) -> NSLayoutConstraint {
        return self.greaterThanOrEqual(to: minimum)
    }
}
