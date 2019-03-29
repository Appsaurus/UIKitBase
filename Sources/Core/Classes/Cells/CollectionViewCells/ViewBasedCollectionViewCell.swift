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
        return self.createMainView()
    }()
    
    open lazy var mainViewInsets: LayoutPadding = {
        return .zero
    }()
    
    open override func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubview(view)
    }
    
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        view.forceSuperviewToMatchContentSize(insetBy: mainViewInsets)
    }
    
    open func createMainView() -> View{
        return View()
    }
    
}
