//
//  SimpleHorizontalStackTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 7/17/17.
//
//

import Layman
import Swiftest

open class SimpleHorizontalStackTableViewCell: DynamicHeightCell {
    open var stackViewLayoutInsets = LayoutPadding(10.0, 5.0)
    open var stackView = HorizontalStackView()

    override open func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(self.stackView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.stackView.forceSuperviewToMatchContentSize()
    }
}
