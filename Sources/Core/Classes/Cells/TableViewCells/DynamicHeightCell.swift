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

    open override func initProperties() {
        super.initProperties()
        selectionStyle = .none
    }

    open override func createSubviews() {
        super.createSubviews()
        contentView.addSubview(mainLayoutView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        mainLayoutView.forceSuperviewToMatchContentSize(insetBy: mainLayoutViewInsets)
    }
}
