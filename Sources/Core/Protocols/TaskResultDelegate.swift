//
//  AsyncTaskDelegate.swift
//  Pods
//
//  Created by Brian Strobach on 8/9/17.
//  Copyright © 2017 Appsaurus. All rights reserved.
//

import Foundation
import Swiftest

public protocol OptionalTaskResultDelegate: AnyObject {
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
    var result: TaskResult? { get set }
}

public extension OptionalTaskResultDelegate {
    typealias TaskCompletionClosure = (result: ClosureIn<TaskResult?>, cancelled: VoidClosure)

    func setOnDidFinishTask(_ completion: TaskCompletionClosure) {
        onDidFinishTask = completion
    }

    func finishTask() {
        onDidFinishTask?.result(result)
    }

    func finishTask(with result: TaskResult) {
        self.result = result
        finishTask()
    }

    func cancelTask() {
        onDidFinishTask?.cancelled()
    }
}

public protocol TaskResultDelegate: AnyObject {
    associatedtype TaskResult
    var onDidFinishTask: TaskCompletionClosure? { get set }
    var result: TaskResult? { get set }
}

public extension TaskResultDelegate {
    typealias TaskCompletionClosure = (result: ClosureIn<TaskResult>, cancelled: VoidClosure)

    func setOnDidFinishTask(_ completion: TaskCompletionClosure) {
        onDidFinishTask = completion
    }

    func finishTask() {
        guard let result = result else {
            return
        }
        onDidFinishTask?.result(result)
    }

    func finishTask(with result: TaskResult) {
        self.result = result
        finishTask()
    }

    func cancelTask() {
        onDidFinishTask?.cancelled()
    }
}

public protocol DelegatedTaskCoordinator: AnyObject {
    associatedtype FinalTaskResult
    var onDidFinishFinalTask: FinalTaskCompletionClosure? { get set }
    func coordinateResultsOf<TM: TaskResultDelegate>(delegates: [TM])
}

public extension DelegatedTaskCoordinator {
    typealias FinalTaskCompletionClosure = (_ result: FinalTaskResult?) -> Void
}
