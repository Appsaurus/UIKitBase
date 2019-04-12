//
//  AsyncDatasourceChangeManager.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/11/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation
import Swiftest

public typealias AsyncDatasourceChange = (_ completion: @escaping VoidClosure) -> Void

// For queuing collection reloads serially and atomically.
public protocol AsyncDatasourceChangeManager: AnyObject {
    var asyncDatasourceChangeQueue: [AsyncDatasourceChange] { get set }
    var uponQueueCompletion: VoidClosure? { get set }
    func enqueue(_ modification: @escaping AsyncDatasourceChange)
    func performNextModification()
}


extension AsyncDatasourceChangeManager {
    public func enqueue(_ modification: @escaping AsyncDatasourceChange) {
        asyncDatasourceChangeQueue.enqueue(modification)
        if asyncDatasourceChangeQueue.count == 1 {
            performNextModification()
        }
    }

    public func performNextModification() {
        guard let modification = asyncDatasourceChangeQueue.peekAtQueue() else {
            uponQueueCompletion?()
            uponQueueCompletion = nil
            return
        }
        modification { [weak self] in
            guard let self = self else { return }
            _ = self.asyncDatasourceChangeQueue.dequeue()
            self.performNextModification()
        }
    }
}
