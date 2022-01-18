//
//  Bindable.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/30/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import DarkMagic
import Foundation

public protocol ModelDisplayable: AnyObject {
    associatedtype Model
    func display(model: Model)
    func displayEmptyModelState()
}

public extension ModelDisplayable {
    func displayEmptyModelState() {}
}

public protocol ModelBindable: AnyObject {
    associatedtype Model
    var model: Model? { get set }
    func bind(model: Model?)
    func modelDidChange()
}

public extension ModelBindable {
    func bind(model: Model?) {
        self.model = model
//        debugPrint("Need to implement binding here")
        modelDidChange()
    }
}

public extension ModelBindable where Self: ModelDisplayable {
    func modelDidChange() {
        guard let model = self.model else {
            displayEmptyModelState()
            return
        }
        display(model: model)
    }
}

public extension ModelBindable where Self: SyncListener, Model: Synchronizable {
    func bind(model: Model?) {
        if let existingModel = self.model, let existingSyncAction = syncActions[existingModel.typedSyncID] {
            existingModel.stopObservingSync(action: existingSyncAction)
        }
        self.model = model
        if let model = model {
            syncActions[model.typedSyncID] = model.onSync(self.modelDidChange)
        }
        self.modelDidChange()
    }
}

private var associatedModel: String = "associatedModel"
public extension ModelBindable where Self: NSObject {
    var model: Model? {
        get {
            return getAssociatedObject(for: &associatedModel, initialValue: nil)
        }
        set {
            setAssociatedObject(newValue, for: &associatedModel)
        }
    }
}

public typealias ViewModelBindable = ModelDisplayable & ModelBindable
public typealias SyncViewModelBindable = ViewModelBindable & SyncListener

public protocol ModelBound: AnyObject {
    associatedtype Model
    var model: Model { get set }
    func bind(model: Model)
    func modelDidChange()
}

public extension ModelBound {
    func bind(model: Model) {
        self.model = model
        self.modelDidChange()
    }

    func modelDidChange() {}
}

import Actions
import protocol Actions.Action

public protocol SyncListener: NSObject {}

private let syncActionsAssociated = AssociatedObjectKey<[String: Action]>("syncActionsAssociated")

public extension SyncListener {
    var syncActions: [String: Action] {
        get {
            return self[syncActionsAssociated, [:]]
        }
        set {
            self[syncActionsAssociated] = newValue
        }
    }
}

extension ModelBound where Self: SyncListener, Model: Synchronizable {
    func bind(model: Model) {
        if let existingSyncAction = syncActions[self.model.typedSyncID] {
            self.model.stopObservingSync(action: existingSyncAction)
        }
        self.model = model
        syncActions[model.typedSyncID] = model.onSync(self.modelDidChange)
        self.modelDidChange()
    }
}

public extension ModelBound where Self: ModelDisplayable {
    func modelDidChange() {
        display(model: model)
    }
}

public typealias ViewModelBound = ModelDisplayable & ModelBound

public typealias SyncViewModelBound = ViewModelBound & SyncListener

public extension ModelBound where Self: NSObject {
    var model: Model {
        get {
            return getAssociatedObject(for: &associatedModel)!
        }
        set {
            setAssociatedObject(newValue, for: &associatedModel)
        }
    }
}
