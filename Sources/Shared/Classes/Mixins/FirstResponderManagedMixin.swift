//
//  FirstResponderManagedMixin.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 12/3/18.
//

import UIKitMixinable

open class FirstResponderManagedMixin: UIViewControllerMixin<UIViewController & FirstResponderManaged>{
    open override func viewWillAppear(_ animated: Bool) {
        mixable.firstResponderManagedWillAppear()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        mixable.firstResponderManagedWillDissappear()
    }
}
