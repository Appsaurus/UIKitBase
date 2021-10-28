//
//  Synchronizable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/30/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Actions
import Foundation
import RuntimeExtensions
import Swiftest

extension Notification.Name {
    public static func synchronizableDidChange(id: String) -> Notification.Name {
        return Notification.Name(rawValue: "synchronizableDidChange_\(id)")
    }
}

public extension Synchronizable {
    @discardableResult
    func onSync(_ action: @escaping VoidClosure) -> Action {
        NotificationCenter.default.observe(.synchronizableDidChange(id: typedSyncID), action: action)
    }

    func stopObservingSync(action: Action) {
        NotificationCenter.default.stopObserving(action: action)
    }
}

public func pointer(_ reference: AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(reference).toOpaque()
}

public func typeIdentifier(_ object: AnyObject) -> ObjectIdentifier {
    let objectIdentifier = ObjectIdentifier(type(of: object))
    return objectIdentifier
}

public protocol Synchronizable: KVC {
    func syncReferences()
    var syncID: String { get }
    func updateWithValues<T: Synchronizable>(of object: T)
}

public extension Synchronizable {
    func updateWithValues<T: Synchronizable>(of object: T) {
        _ = try? updateWithKeyValues(of: object)
    }
}

extension Synchronizable {
    private var proxySyncID: String? {
        return ModelSync.sharedInstance.proxySyncIDMap[self.typeId]?(self)
    }

    private var typeId: ObjectIdentifier {
        return typeIdentifier(self)
    }

    fileprivate var _internalSyncID: String {
        if let proxy = proxySyncID {
            return "\(self.typeId)_\(proxy)"
        }
        return self.typedSyncID
    }

    public var observableDebugDescription: String {
        let proxyString: String = self.proxySyncID != nil ? "proxy" : ""
        return "ObjectReference: \(self) | \(proxyString)ReferenceId: \(self._internalSyncID) | Pointer: \(pointer(self))"
    }

    public var typedSyncID: String {
        return "\(self.typeId)_\(syncID)" // .hashValue
    }

    public func syncReferences() {
        ModelSync.sharedInstance.syncReferences(self)
    }
}

public extension Collection where Iterator.Element: Synchronizable {
    func syncReferences() {
        for element: Synchronizable in self {
            element.syncReferences()
        }
    }
}

public class ModelSync {
    public static let sharedInstance = ModelSync()
    public var logsActivity: Bool = false
    var referenceMap: [String: NSHashTable<AnyObject>] = [:]
    var proxySyncIDMap: [ObjectIdentifier: (Synchronizable) -> String] = [:]

    public func syncReferences<T: Synchronizable>(_ objects: [T]) {
        objects.forEach { object in
            syncReferences(object)
        }
    }

    public func overrideReferenceIdHash<T: Synchronizable>(for type: T.Type, _ idWork: @escaping (Synchronizable) -> String) {
        self.proxySyncIDMap[ObjectIdentifier(type)] = idWork
    }

    public func syncReferences<T: Synchronizable>(_ object: T) {
        let referencedId: String = object._internalSyncID

        // If there is no table for a given object id, create one including first reference and return
        guard let existingObjectReferences: NSHashTable<T> = referenceMap[referencedId] as? NSHashTable<T> else {
            if self.logsActivity { print("Creating reference map for \(object.observableDebugDescription)") }
            let referenceHashTable = NSHashTable<AnyObject>(options: NSPointerFunctions.Options.weakMemory)
            referenceHashTable.add(object)
            self.referenceMap[referencedId] = referenceHashTable
            return
        }

        if self.logsActivity { print("Syncing \(object.observableDebugDescription)") }
        // If there are any existing references, update them with the data from the freshest copy of the object
        lock(existingObjectReferences) {
            let existingObjects: [T] = existingObjectReferences.allObjects
            existingObjects.forEach { existingObject in
                lock(existingObject) {
                    existingObject.updateWithValues(of: object)
                }
            }
            existingObjectReferences.add(object)
            NotificationCenter.post(name: .synchronizableDidChange(id: referencedId))
        }
    }

    private func resolve<T: Synchronizable>(referenceId: String, forObjectOf type: T.Type) -> String {
        let objectIdentifier = "\(ObjectIdentifier(type))"
        let referenceId = referenceId.starts(with: objectIdentifier) ? referenceId : "\(objectIdentifier)_\(referenceId)"
        return referenceId
    }

    public func getSynchronizedReferences<T: Synchronizable>(of type: T.Type = T.self, with referenceId: String) -> [T]? {
        let resolvedId = self.resolve(referenceId: referenceId, forObjectOf: type)
        return (self.referenceMap[resolvedId] as? NSHashTable<T>)?.allObjects
    }

    public func getSynchronizedReference<T: Synchronizable>(of type: T.Type = T.self, with referenceId: String) -> T? {
        return self.getSynchronizedReferences(of: type, with: referenceId)?.first
    }

    // Returns true if reference exists and modifications will be applied
    @discardableResult
    public func modifySynchronizedReference<T: Synchronizable>(of type: T.Type = T.self, with referenceId: String, modifications: (T) -> Void) -> Bool {
        guard let referenceObject: T = getSynchronizedReference(of: type, with: referenceId) else {
            return false
        }
        modifications(referenceObject)
        referenceObject.syncReferences()
        return true
    }
}
