//
//  ButtonAuthController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest
import UIKitExtensions

public typealias AuthButton = BaseUIButton & AuthView

open class ButtonAuthController<R: Codable, V: AuthButton>: AuthController<R, V> {
    open override func didInit() {
        super.didInit()
        setupAuthAction(for: authView)
    }
}
