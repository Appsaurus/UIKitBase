//
//  FormInput.swift
//  FormToolbar
//
//  Created by Suguru Kishimoto on 2/18/17.
//  Copyright © 2017 Suguru Kishimoto. All rights reserved.
//

import Foundation
import UIKit
/// FormInput protocol
/// Handle UITextField and UITextView in the same way.
public protocol FormInput: NSObjectProtocol {
    var _inputAccessoryView: UIView? { get set }
    var responder: UIResponder { get }
//    var view: UIView { get }
}

extension FormField: FormInput {
    public var responder: UIResponder {
        return proxyFirstResponder() ?? self
    }

    public var view: UIView {
        return canBecomeFirstResponder ? self : contentView
    }
}

extension UITextField: FormInput {
    public var _inputAccessoryView: UIView? {
        get {
            return inputAccessoryView
        }
        set {
            inputAccessoryView = newValue
        }
    }

    public var responder: UIResponder {
        return self
    }

    public var view: UIView {
        return self
    }
}

extension UITextView: FormInput {
    public var _inputAccessoryView: UIView? {
        get {
            return inputAccessoryView
        }
        set {
            inputAccessoryView = newValue
        }
    }

    public var responder: UIResponder {
        return self
    }

    public var view: UIView {
        return self
    }
}
