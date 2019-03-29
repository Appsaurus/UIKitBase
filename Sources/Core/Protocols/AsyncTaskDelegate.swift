//
//  AsyncTaskDelegate.swift
//  Pods
//
//  Created by Brian Strobach on 8/9/17.
//  Copyright © 2017 Appsaurus. All rights reserved.
//

import Foundation
import Swiftest
public protocol AsyncTaskOptionalResultDelegate: class{
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
}

public extension AsyncTaskOptionalResultDelegate{
    public typealias TaskCompletionClosure = (_ result: TaskResult?) -> Void
    
}

public protocol AsyncTaskDelegate: class{
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
}

public extension AsyncTaskDelegate{
    public typealias TaskCompletionClosure = (result: ClosureIn<TaskResult>, cancelled: VoidClosure)
    public func setOnDidFinishTask(_ completion: TaskCompletionClosure){
        self.onDidFinishTask = completion
    }
    
}

public protocol AsyncTaskDelegateCoordinator: class{
    associatedtype FinalTaskResult
    var onDidFinishFinalTask: FinalTaskCompletionClosure? { get set }
    func cooridnateTasksOf<TM: AsyncTaskDelegate>(managers: [TM])
}

public extension AsyncTaskDelegateCoordinator{
    
    public typealias FinalTaskCompletionClosure = (_ result: FinalTaskResult?) -> Void
    
}
