//
//  FooterView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import UIKit
import Swiftest
import UILayoutKit

open class FooterView<View: UIView>: BaseView {
    
    open lazy var contentView: View = {
        return self.createContentView()
    }()
    
    open lazy var contentViewInsets: UIEdgeInsets = {
        return .zero
    }()
    
    public init(contentView: View? = nil, contentViewInsets: UIEdgeInsets? = nil) {
        super.init(callDidInit: false)
        self.contentView =? contentView
        self.contentViewInsets =? contentViewInsets
        didInitProgramatically()
    }
    
    public override init(callDidInit: Bool) {
        super.init(callDidInit: callDidInit)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func createSubviews() {
        super.createSubviews()
        addSubview(contentView)
    }
    
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        contentView.autoPinToSuperview(withInsets:  contentViewInsets)
    }
    
    open func createContentView() -> View{
        return View()
    }
    
    //MARK: Layout in superview
    @discardableResult
    open func autoLayoutPin(toBottomOf view: UIView, height: CGFloat? = nil) -> ConstraintDictionary{
        var constraints: ConstraintDictionary = [:]
        let height = height ?? 75.0
        
        if let tableView: UITableView = view as? UITableView{
            tableView.tableFooterView = self
            //            self.autoMatchWidth(of: tableView)
            //            constraints[.height] = autoSizeHeight(to: height)
            self.w = tableView.w
            self.h = height
            return constraints
        }
        
        if self.superview != view{
            view.addSubview(self)
        }
        constraints = autoPinToSuperview(edges: .leftAndRight)
        constraints[.height] = autoSizeHeight(to: height)
        if #available(iOS 11.0, *) {
            anchorBottom(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            constraints[.bottom] = autoPinToSuperview(edge: .bottom, withOffset: 0.0)
        }
        return constraints
    }
}

extension UIViewController{
    @discardableResult
    public func add<View>(footerView: FooterView<View>, height: CGFloat? = nil) -> ConstraintDictionary{
        return footerView.autoLayoutPin(toBottomOf: self.view, height: height)
    }
}

extension UIView{
    @discardableResult
    public func add<View>(footerView: FooterView<View>, height: CGFloat? = nil) -> ConstraintDictionary{
        return footerView.autoLayoutPin(toBottomOf: self, height: height)
    }
}
