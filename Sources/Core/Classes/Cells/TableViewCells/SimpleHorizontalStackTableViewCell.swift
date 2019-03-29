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
    open var stackViewLayoutInsets: LayoutPadding = LayoutPadding(10.0, 5.0)
    open var stackView: HorizontalStackView = HorizontalStackView()

    open override func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(stackView)

    }
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.forceSuperviewToMatchContentSize()
    }
}
