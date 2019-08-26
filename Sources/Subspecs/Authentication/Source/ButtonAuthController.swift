//
//  ButtonAuthController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest
import UIKitExtensions

public typealias AuthButton = BaseButton & AuthView

open class ButtonAuthController<R: Codable, V: AuthButton>: AuthController<R> {

    public required init(button: V,
                         delegate: AuthControllerDelegate,
                         onCompletionHandler: @escaping ResultClosure<R>){
        super.init(delegate: delegate, onCompletionHandler: onCompletionHandler)
        setupAuthAction(for: button)
    }

    required public init(delegate: AuthControllerDelegate, onCompletionHandler: @escaping ResultClosure<R>) {
        super.init(delegate: delegate, onCompletionHandler: onCompletionHandler)
    }

    // MARK: Convenience
    open func setupAuthAction(for button: BaseButton) {
        button.onTap = _authenticate
    }
}
