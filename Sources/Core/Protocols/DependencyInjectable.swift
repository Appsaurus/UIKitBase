//
//  DependencyInjectable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/3/18.
//

import DarkMagic
import Foundation

public protocol DependencyInjectable: AnyObject {
    func assertDependencies()
    func confirmDependencies() -> Bool
    //    func unresolvedDependencies() -> [String]
    var requiredDependencies: [Any?] { get set }
    var requiresOneOfDependencies: [Any?] { get set }
}

private extension AssociatedObjectKeys {
    static let requiredDependencies = AssociatedObjectKey<[Any?]>("requiredDependencies")
    static let requiresOneOfDependencies = AssociatedObjectKey<[Any?]>("requiresOneOfDependencies")
}

public extension DependencyInjectable where Self: NSObject {
    var requiredDependencies: [Any?] {
        get {
            return self[.requiredDependencies, []]
        }
        set {
            self[.requiredDependencies] = newValue
        }
    }

    var requiresOneOfDependencies: [Any?] {
        get {
            return self[.requiresOneOfDependencies, []]
        }
        set {
            self[.requiresOneOfDependencies] = newValue
        }
    }
}

public extension DependencyInjectable {
    func assertDependencies() {
        assert(self.confirmDependencies(), "Failed to resolve dependencies for class \(String(describing: self))")
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

    func unresolvedDependencies() -> [Any?] {
        var missingReqDependencies: [Any?] = self.requiredDependencies.filter { value -> Bool in
            value == nil
        }

        if self.requiresOneOfDependencies.count != 0 {
            let hasOne = self.requiresOneOfDependencies.contains { value -> Bool in
                value != nil
            }
            if !hasOne {
                missingReqDependencies.append(contentsOf: self.requiresOneOfDependencies)
            }
        }
        return missingReqDependencies
    }

    /// Checks if dependency references are instantiated.
    ///
    /// - Returns: True if depdencies are valid. False if any dependency is missing.
    func confirmDependencies() -> Bool {
        let allRequired = !self.requiredDependencies.contains { value -> Bool in
            value == nil
        }
        if !allRequired { return false }

        if self.requiresOneOfDependencies.count == 0 {
            return true
        }
        return self.requiresOneOfDependencies.contains { value -> Bool in
            value != nil
        }
    }
}
