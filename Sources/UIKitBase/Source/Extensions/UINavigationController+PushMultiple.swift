//
//  UINavigationController+PushMultiple.swift
//  UIKitBase
//
//  Created by Brian Strobach on 2/9/22.
//

import UIKit
import Swiftest

public extension UINavigationController {
    func push(all viewControllers: [UIViewController], animated: Bool, completion: VoidClosure? = nil) {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            self.setViewControllers(self.viewControllers + viewControllers, animated: animated)
            CATransaction.commit()
    }
}

public extension UIViewController {
    func push(_ viewControllers: [UIViewController], animated: Bool, completion: VoidClosure? = nil) {
        self.navigationController?.push(all : viewControllers, animated: animated, completion: completion)
    }
}
