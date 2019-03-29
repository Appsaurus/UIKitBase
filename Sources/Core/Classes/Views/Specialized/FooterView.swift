//
//  FooterView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import UIKit
import Swiftest
import Layman
import UIKitExtensions

open class FooterView<View: UIView>: BaseView {
    
    open lazy var contentView: View = {
        return self.createContentView()
    }()

    public init(contentView: View? = nil) {
        super.init(callDidInit: false)
        self.contentView =? contentView
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
        contentView.edges.equal(to: margins.edges)
    }
    
    open func createContentView() -> View {
        return View()
    }
    
    // MARK: Layout in superview
    @discardableResult
    open func autoLayoutPin(toBottomOf view: UIView, height: CGFloat? = nil) -> ConstraintAttributeMap {
        var constraints: ConstraintAttributeMap = [:]
        let height = height ?? 75.0
        
        if let tableView: UITableView = view as? UITableView {
            tableView.tableFooterView = self
            //            self.autoMatchWidth(of: tableView)
            //            constraints[.height] = autoSizeHeight(to: height)
            self.frame.w = tableView.frame.w
            self.frame.h = height
            return constraints
        }
        
        if self.superview != view {
            view.addSubview(self)
        }
        constraints[.leading] = [leading.equal(to: assertSuperview.leading)]
        constraints[.trailing] = [trailing.equal(to: assertSuperview.trailing)]
        constraints[.height] = [self.height.equal(to: height)]
        if #available(iOS 11.0, *) {
            constraints[.bottom] = [bottom.equal(to: view.safeAreaLayoutGuide.bottom)]
        } else {
            constraints[.bottom] = [bottom.equal(to: view.bottom)]
        }
        return constraints
    }
}

extension UIViewController {
    @discardableResult
    public func add<View>(footerView: FooterView<View>, height: CGFloat? = nil) -> ConstraintAttributeMap {
        return footerView.autoLayoutPin(toBottomOf: self.view, height: height)
    }
}

extension UIView {
    @discardableResult
    public func add<View>(footerView: FooterView<View>, height: CGFloat? = nil) -> ConstraintAttributeMap {
        return footerView.autoLayoutPin(toBottomOf: self, height: height)
    }
}
