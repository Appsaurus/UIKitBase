//
//  InitialAutoLayoutPassAware.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 12/3/18.
//

import Foundation
import DarkMagic

public protocol InitialAutoLayoutPassAware: class{
    var didInitialAutolayoutPass: Bool { get set }
    func didFinishInitialAutoLayoutPass()
}

private extension AssociatedObjectKeys{
    static let didInitialAutolayoutPass = AssociatedObjectKey<Bool>("didInitialAutolayoutPass")
}

public extension InitialAutoLayoutPassAware where Self: NSObject{
    
    public var didInitialAutolayoutPass: Bool{
        get{
            return self[.didInitialAutolayoutPass, false]
        }
        set{
            self[.didInitialAutolayoutPass] = newValue
        }        
    }
    
}
