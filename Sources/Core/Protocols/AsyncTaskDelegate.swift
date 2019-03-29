//
//  AsyncTaskDelegate.swift
//  Pods
//
//  Created by Brian Strobach on 8/9/17.
//  Copyright © 2017 Appsaurus. All rights reserved.
//

import Foundation
import Swiftest
public protocol AsyncTaskOptionalResultDelegate: AnyObject {
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
}

public extension AsyncTaskOptionalResultDelegate {
    typealias TaskCompletionClosure = (_ result: TaskResult?) -> Void
}

public protocol AsyncTaskDelegate: AnyObject {
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
}

public extension AsyncTaskDelegate {
    typealias TaskCompletionClosure = (result: ClosureIn<TaskResult>, cancelled: VoidClosure)
    func setOnDidFinishTask(_ completion: TaskCompletionClosure) {
        onDidFinishTask = completion
    }
}

public protocol AsyncTaskDelegateCoordinator: AnyObject {
    associatedtype FinalTaskResult
    var onDidFinishFinalTask: FinalTaskCompletionClosure? { get set }
    func cooridnateTasksOf<TM: AsyncTaskDelegate>(managers: [TM])
}

public extension AsyncTaskDelegateCoordinator {
    typealias FinalTaskCompletionClosure = (_ result: FinalTaskResult?) -> Void
}
