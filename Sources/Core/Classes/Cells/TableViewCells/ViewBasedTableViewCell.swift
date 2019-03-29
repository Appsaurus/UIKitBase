//
//  ViewBasedTableViewCell.swift
//  Pods
//
//  Created by Brian Strobach on 6/16/17.
//
//

import Layman

open class ViewBasedTableViewCell<View: UIView>: DynamicHeightCell {

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
