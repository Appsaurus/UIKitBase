//
//  FirstResponderManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import Foundation
import DarkMagic

public protocol FirstResponderManaged{
    var endsEditingOnDisappearance: Bool { get set }
    var persistsFirstResponderBetweenAppearances: Bool { get set }
    var firstResponderOnNextAppearance: UIResponder? { get set }
}

extension FirstResponderManaged{
    func restoreLastFirstResponder(){
        guard let responder = firstResponderOnNextAppearance else { return }
        responder.becomeFirstResponder()
    }
}
extension FirstResponderManaged where Self: UIViewController{
    
    mutating func firstResponderManagedWillDissappear(){
        if persistsFirstResponderBetweenAppearances{
            firstResponderOnNextAppearance = view.firstResponder
        }
        if endsEditingOnDisappearance{
            view.endEditing(true)
        }
    }
    
    func firstResponderManagedWillAppear(){
        guard persistsFirstResponderBetweenAppearances else { return }
        restoreLastFirstResponder()
    }
}

private extension AssociatedObjectKeys{
    static let lastFirstResponder = AssociatedObjectKey<UIResponder>("lastFirstResponder")
    static let persistsFirstResponderBetweenAppearances = AssociatedObjectKey<Bool>("persistsFirstResponderBetweenAppearances")
    static let endsEditingOnDisappearance = AssociatedObjectKey<Bool>("endsEditingOnDisappearance")
}

public extension FirstResponderManaged where Self: NSObject{
    
    public var firstResponderOnNextAppearance: UIResponder?{
        get{
            return self[.lastFirstResponder]
        }
        set{
            self[.lastFirstResponder] = newValue
        }
    }

    public var persistsFirstResponderBetweenAppearances: Bool{
        get{
            return self[.persistsFirstResponderBetweenAppearances, true]
        }
        set{
            self[.persistsFirstResponderBetweenAppearances] = newValue
        }
    }
    
    public var endsEditingOnDisappearance: Bool{
        get{
            return self[.endsEditingOnDisappearance, true]
        }
        set{
            self[.endsEditingOnDisappearance] = newValue
        }
    }
}