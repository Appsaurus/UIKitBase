//
//  ViewBasedTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 6/16/17.
//
//

import Layman

open class ViewBasedTableViewCell<View: UIView>: DynamicHeightCell {
    open lazy var view: View = self.createMainView()

    open lazy var mainViewInsets: LayoutPadding = .zero

    override open func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(self.view)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.view.forceSuperviewToMatchContentSize(insetBy: self.mainViewInsets)
    }

    open func createMainView() -> View {
        return View()
    }
}
