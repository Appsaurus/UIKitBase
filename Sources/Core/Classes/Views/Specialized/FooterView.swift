//
//  FooterView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Layman
import Swiftest
import UIKit
import UIKitExtensions

open class FooterView<View: UIView>: BaseView {
    open lazy var contentView: View = {
        self.createContentView()
    }()

    public init(contentView: View? = nil) {
        super.init(callInitLifecycle: false)
        self.contentView =? contentView
        initLifecycle(.programmatically)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.contentView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.contentView.edges.equal(to: margins.edges)
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
            frame.w = tableView.frame.w
            frame.h = height
            return constraints
        }

        if superview != view {
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
        return footerView.autoLayoutPin(toBottomOf: view, height: height)
    }
}

extension UIView {
    @discardableResult
    public func add<View>(footerView: FooterView<View>, height: CGFloat? = nil) -> ConstraintAttributeMap {
        return footerView.autoLayoutPin(toBottomOf: self, height: height)
    }
}
