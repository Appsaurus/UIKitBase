//
//  HeadlineLabelStack.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Layman
import UIKit

public class HeadlineLabelStack: BaseStackView {
    var headlineLabel = HeadlineLabel()
    var subheadlineLabel = SubheadlineLabel()
    var labels: [UILabel] {
        return [headlineLabel, subheadlineLabel]
    }

    override public func createSubviews() {
        super.createSubviews()
        stackView.stack(self.labels)
        stackView.apply(stackViewConfiguration: .equalSpacingVertical(alignment: .center,
                                                                      spacing: 20))
    }

    override public func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.height.autoExpand()
        self.enforceContentSize()
        self.labels.enforceContentSize()
    }
}
