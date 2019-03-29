//
//  KeyboardMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/16/18.
//

import UIKit
import Swiftest

public protocol KeyboardSizeAware: class {
    var keyboardHeight: CGFloat? { set get }
}

extension KeyboardSizeAware{
    public func registerKeyboard() {

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            self.keyboardHeight = nil
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardHeight = keyboardSize.height
            }
        }
    }
    
    public func deregisterKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}


