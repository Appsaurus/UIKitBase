//
//  StatefulViewControllerErrorView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/12/15.
//  Copyright © 2015 Appsaurus. All rights reserved.
//

import Swiftest
import UIKit

open class StatefulViewControllerErrorView: StatefulViewControllerView {

    public func show(error: Error, retry: VoidClosure? = nil) {
        guard let retry = retry else {
            set(message: error.localizedDescription)
            return
        }
        set(message: error.localizedDescription, responseButtonTitle: "Try Again", responseAction: retry)
    }
}
