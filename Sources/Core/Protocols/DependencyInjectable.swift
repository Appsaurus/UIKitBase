//
//  DependencyInjectable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import Foundation
import DarkMagic

public protocol DependencyInjectable: class{
    func assertDependencies()
    func confirmDependencies() -> Bool
    //    func unresolvedDependencies() -> [String]
    var requiredDependencies: [Any?] { get set }
    var requiresOneOfDependencies: [Any?] { get set }
}

private extension AssociatedObjectKeys{
    static let requiredDependencies = AssociatedObjectKey<[Any?]>("requiredDependencies")
    static let requiresOneOfDependencies = AssociatedObjectKey<[Any?]>("requiresOneOfDependencies")
}

public extension DependencyInjectable where Self: NSObject{
    
    public var requiredDependencies: [Any?]{
        get{
            return self[.requiredDependencies, []]
        }
        set{
            self[.requiredDependencies] = newValue
        }
    }
    
    public var requiresOneOfDependencies: [Any?]{
        get{
            return self[.requiresOneOfDependencies, []]
        }
        set{
            self[.requiresOneOfDependencies] = newValue
        }
    }
    
}
extension DependencyInjectable{
    public func assertDependencies(){
        assert(confirmDependencies(), "Failed to resolve dependencies for class \(String(describing: self))")
    }
    //    public func assertDependencies(){
    //        var unresolvedDependencies: [Any?] = self.unresolvedDependencies()
    //        guard unresolvedDependencies.count == 0 else{
    //            var failureMessage: String = "Failed to resolve dependencies of type for class \(String(describing: self)):"
    //            for dep in unresolvedDependencies{
    //                let depMirror: Mirror = Mirror(reflecting: dep)
    //
    //                failureMessage += "\n\(depMirror.description) \(depMirror.subjectType)"
    //            }
    //            assertionFailure(failureMessage)
    //            return
    //        }
    //
    //
    //    }
    
    
    public func unresolvedDependencies() -> [Any?]{
        var missingReqDependencies: [Any?] = requiredDependencies.filter({ (value) -> Bool in
            value == nil
        })
        
        if requiresOneOfDependencies.count != 0{
            let hasOne = requiresOneOfDependencies.contains { (value) -> Bool in
                return value != nil
            }
            if !hasOne{
                missingReqDependencies.append(contentsOf: requiresOneOfDependencies)
            }
        }
        return missingReqDependencies
    }
    
    /// Checks if dependency references are instantiated.
    ///
    /// - Returns: True if depdencies are valid. False if any dependency is missing.
    public func confirmDependencies() -> Bool{
        
        let allRequired = !requiredDependencies.contains { (value) -> Bool in
            return value == nil
        }
        if !allRequired { return false }
        
        if requiresOneOfDependencies.count == 0{
            return true
        }
        return requiresOneOfDependencies.contains { (value) -> Bool in
            return value != nil
        }
    }
}


