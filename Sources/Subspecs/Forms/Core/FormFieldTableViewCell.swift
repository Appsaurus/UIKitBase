//
//  FormFieldCell.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/17.
//
//

import Layman
import Swiftest

open class FormFieldCell: DynamicHeightCell {
    open var field: View

    public init(field: View, insets: LayoutPadding? = nil) {
        self.field = field
        super.init(callDidInit: false)
        mainViewInsets =? insets
        didInitProgramatically()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open lazy var mainViewInsets: LayoutPadding = {
        .zero
    }()

    open override func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(field)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        field.forceSuperviewToMatchContentSize(insetBy: mainViewInsets)
//        field.autoPinToSuperview(edges: .leftAndRight, withInsets: mainViewInsets)
//        mainLayoutView.autoExpandHeight(toFitHeightOf: [field], topPadding: mainViewInsets.top, bottomPadding: mainViewInsets.bottom)
//        field.height.greaterThanOrEqual(to: 0.0)
//        field.resistCompression()
    }
}
