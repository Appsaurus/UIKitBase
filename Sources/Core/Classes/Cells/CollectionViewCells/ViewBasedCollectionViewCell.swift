//
//  ViewBasedCollectionViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 7/9/17.
//
//

import Layman

open class ViewBasedCollectionViewCell<View: UIView>: DynamicSizeCollectionViewCell {
    open lazy var view: View = {
        self.createMainView()
    }()

    open lazy var mainViewInsets: LayoutPadding = {
        .zero
    }()

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
