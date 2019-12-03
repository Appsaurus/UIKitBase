//
//  ManualScrollViewContentManagerMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/19.
//

import Foundation
import UIKitMixinable

public class ManualScrollViewContentManagerMixin: UIViewControllerMixin<UIViewController> {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        mixable.manuallyManageScrollViewContentInsets()
    }
}

public protocol ScrollViewReferencing {
    var scrollView: UIScrollView { get }
}

extension UITableViewController: ScrollViewReferencing  {
    public var scrollView: UIScrollView {
        return tableView
    }
}

extension UICollectionViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return collectionView!
    }
}

extension BaseContainedTableViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return tableView
    }
}

extension BaseContainedCollectionViewController: ScrollViewReferencing {
    public var scrollView: UIScrollView {
        return collectionView
    }
}

public extension UIViewController {
    func manuallyManageScrollViewContentInsets() {
        if #available(iOS 11.0, *) {
            (self as? ScrollViewReferencing)?.scrollView.contentInsetAdjustmentBehavior = .never
            (self as? BaseScrollviewController)?.containerScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    func automaticallyAdjustScrollViewContentInsets() {
        if #available(iOS 11.0, *) {
            (self as? ScrollViewReferencing)?.scrollView.contentInsetAdjustmentBehavior = .automatic
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
    }
}


open class ViewEdgesLayoutMixin: UIViewControllerMixin<UIViewController>{
    open override func initProperties() {
        super.initProperties()
        mixable.edgesForExtendedLayout = .all
        mixable.extendedLayoutIncludesOpaqueBars = false
        if #available(iOS 11.0, *) {
            mixable.additionalSafeAreaInsets = .zero
        }
    }
}
