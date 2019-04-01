//
//  ButtonAuthController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/10/18.
//

import Swiftest

open class ThirdPartyAuthButtonViewModel {
    open var icon: AuthIcons?
    open var fullLoginButtonTitle: String
    public init(icon: AuthIcons?, fullLoginButtonTitle: String) {
        self.icon = icon
        self.fullLoginButtonTitle = fullLoginButtonTitle
    }
}

open class AuthButton: BaseButton, AuthView {
    open override func initProperties() {
        super.initProperties()
        buttonLayout = ButtonLayout(layoutType: .imageLeftTitleCenter)
    }

    open func authenticationDidBegin() {}

    open func authenticationDidSucceed() {}

    open func authenticationDidFail(_ error: Error) {}
}

open class ButtonAuthController<R, V>: AuthController<Any, AuthButton> {
    open override func didInit() {
        setupAuthAction(for: authView)
    }
}
