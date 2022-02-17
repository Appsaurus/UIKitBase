//
//  FormFieldCell.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import Layman
import Swiftest
import UIKitBase

open class FormFieldCell: DynamicHeightCell {
    open var field: View

    public init(field: View, insets: LayoutPadding? = nil) {
        self.field = field
        super.init(callInitLifecycle: false)
        self.mainViewInsets =? insets
        initLifecycle(.programmatically)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open lazy var mainViewInsets: LayoutPadding = .zero

    override open func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(self.field)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.field.forceSuperviewToMatchContentSize(insetBy: self.mainViewInsets)
//        field.autoPinToSuperview(edges: .leftAndRight, withInsets: mainViewInsets)
//        mainLayoutView.autoExpandHeight(toFitHeightOf: [field], topPadding: mainViewInsets.top, bottomPadding: mainViewInsets.bottom)
//        field.height.greaterThanOrEqual(to: 0.0)
//        field.resistCompression()
    }
}
