//
//  BaseStackView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Layman
import UIKit

open class BaseStackView: BaseView {
    public let stackView = StackView()

    override open func createSubviews() {
        addSubview(self.stackView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.stackView.forceSuperviewToMatchContentSize()
    }
}
