//
//  DynamicHeightTableViewAccessoriesMixins.swift
//  UIKitBase
//
//  Created by Brian Strobach on 8/23/19.
//

import Layman
import UIKitExtensions
import UIKitMixinable

public class DynamicHeightTableViewAccessoriesMixins: UIViewControllerMixin<UITableViewReferencing> {
    var viewTypes: [TableViewAccesoryView] = TableViewAccesoryView.allCases
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mixable.managedTableView.dynamicallySizeHeight(of: viewTypes)
    }

//        open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//            mixable.managedTableView.dynamicallySizeHeight(of: viewTypes)
//        }

//        override open func viewWillAppear(_ animated: Bool) {
//            mixable.managedTableView.dynamicallySizeHeight(of: viewTypes)
//        }
}

public enum TableViewAccesoryView: CaseIterable {
    case header
    case footer
}

public extension UITableView {
    private func dynamicallySizeHeight(of view: UIView, withWidth width: LayoutConstant? = nil) {
        view.layoutDynamicHeight(forWidth: width ?? bounds.width)
//        let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        var viewFrame = view.frame
//        // If we don't have this check, viewDidLayoutSubviews() will recurse
//        // repeatedly, causing the app to hang.
//        if height != viewFrame.height {
//            viewFrame.size.height = height
//            view.frame = viewFrame
//        }
    }

    func dynamicallySizeHeight(of views: TableViewAccesoryView...) {
        dynamicallySizeHeight(of: views)
    }

    func dynamicallySizeHeight(of views: [TableViewAccesoryView]) {
        for view in views {
            switch view {
            case .header:
                guard let headerView = tableHeaderView else { continue }
                dynamicallySizeHeight(of: headerView)
                tableHeaderView = headerView
            case .footer:
                guard let footerView = tableFooterView else { continue }
                dynamicallySizeHeight(of: footerView)
                tableFooterView = footerView
            }
        }
    }

    func setupDynamicHeader(_ view: View,
                            insets: LayoutPadding = LayoutPadding(20)) {
        tableHeaderView = View.parentViewFittingContent(of: view, insetBy: insets)
    }

    func setupDynamicFooter(_ view: View,
                            insets: LayoutPadding = LayoutPadding(20)) {
        tableFooterView = View.parentViewFittingContent(of: view, insetBy: insets)
    }
}
