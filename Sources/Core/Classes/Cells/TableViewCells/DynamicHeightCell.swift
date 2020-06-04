//
//  DynamicHeightCell.swift
//  Pods
//
//  Created by Brian Strobach on 7/17/17.
//
//

import Layman
import Swiftest
import UIKitExtensions
import UIKitMixinable
import UIKitTheme

open class DynamicHeightCell: BaseTableViewCell {
    open var mainLayoutView: UIView = UIView()
    open lazy var mainLayoutViewInsets: LayoutPadding = {
        .zero
    }()

    override open func initProperties() {
        super.initProperties()
        selectionStyle = .none
    }

    override open func createSubviews() {
        super.createSubviews()
        contentView.addSubview(self.mainLayoutView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.mainLayoutView.forceSuperviewToMatchContentSize(insetBy: self.mainLayoutViewInsets)
    }
}
