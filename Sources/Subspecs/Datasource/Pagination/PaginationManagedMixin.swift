//
//  PaginationManagedMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/15/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable

open class PaginationManagedMixin: UIViewControllerMixin<UIViewController & PaginationManaged> {
    open override func viewDidLoad() {
        mixable.onDidTransitionMixins.append { [weak mixable] state in
            guard let mixable = mixable else { return }
            mixable.updatePaginatableViews(for: state)
        }
    }

    open override func willDeinit() {
        mixable.paginatableScrollView.loadingControls.clear()
    }

    open override func createSubviews() {
        mixable.setupPaginatable()
    }

    open override func loadAsyncData() {
        mixable.startLoadingData()
    }
}
