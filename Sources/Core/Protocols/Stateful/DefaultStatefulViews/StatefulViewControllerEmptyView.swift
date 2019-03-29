//
//  StatefulViewControllerEmptyView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/5/15.
//  Copyright © 2015 Appsaurus. All rights reserved.
//

import UIKit
import Swiftest

open class StatefulViewControllerEmptyView: StatefulViewControllerView {
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        set(message: "No results")
    }
}
