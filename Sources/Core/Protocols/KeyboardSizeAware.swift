//
//  KeyboardMixin.swift
//  UIKitBase
//
//  Created by Brian Strobach on 11/16/18.
//

import Swiftest
import UIKit

public protocol KeyboardSizeAware: AnyObject {
    var keyboardHeight: CGFloat? { get set }
}

extension KeyboardSizeAware {
    public func registerKeyboard() {
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                   object: nil,
                                                   queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.keyboardHeight = nil
        }
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                                   object: nil,
                                                   queue: nil) { [weak self] notification in
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
