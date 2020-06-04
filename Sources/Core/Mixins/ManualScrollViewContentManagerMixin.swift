//
//  ManualScrollViewContentManagerMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/19.
//

import Foundation
import UIKitMixinable

public class ManualScrollViewContentManagerMixin: UIViewControllerMixin<UIViewController> {
    override open func viewDidLoad() {
        super.viewDidLoad()
        mixable.manuallyManageScrollViewContentInsets()
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

open class ViewEdgesLayoutMixin: UIViewControllerMixin<UIViewController> {
    override open func initProperties() {
        super.initProperties()
        mixable.edgesForExtendedLayout = .all
        mixable.extendedLayoutIncludesOpaqueBars = false
        if #available(iOS 11.0, *) {
            mixable.additionalSafeAreaInsets = .zero
        }
    }
}
