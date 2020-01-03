//
//  StatefulViewController.h
//  UIKitBase
//
//  Created by Brian Strobach on 11/5/15.
//  Copyright Â© 2016 Appsaurus. All rights reserved.
//

import DarkMagic
import Swiftest
import UIKit
import UIKitExtensions
import UIKitMixinable
public typealias State = String

extension State {
    public static let uninitialized = "uninitialized"
    public static let initialized = "initialized"
    public static let loaded = "loaded"
    public static let loading = "loading"
    public static let refreshing = "refreshing"
    public static let refreshingError = "refreshingError"
    public static let error = "error"
    public static let empty = "empty"
    public static let loadingMore = "loadingMore"
    public static let loadedAll = "loadedAll"
    public static let loadMoreError = "loadMoreError"
}

public typealias StatefulViewMap = [State: UIView]

extension Dictionary where Key == State, Value == UIView {
    public static func `default`(for statefulViewController: StatefulViewController) -> StatefulViewMap {
        return StatefulViewControllerDefaults.statefulViews(statefulViewController)
    }
}

public class StatefulViewControllerDefaults {
    public static var statefulViews: (StatefulViewController) -> StatefulViewMap = { vc in
        [.empty: StatefulViewControllerView(viewModel: .empty(retry: vc.reload)),
         .loading: StatefulViewControllerView.defaultLoading,
         .error: StatefulViewControllerView(viewModel: .error)]
    }
}

public protocol StatefulViewController: AnyObject, Reloadable {
    var statefulSuperview: UIView { get }
    var stateMachine: ViewStateMachine { get set }
    var logsStateTransitions: Bool { get set }
    var onDidTransitionMixins: [(State) -> Void] { get set }

    func createViewStateMachine() -> ViewStateMachine
    func customizeStatefulViews()
    func createStatefulViews() -> StatefulViewMap

    func transitionToInitialState()

    // MARK: Transitions

    func transition(to state: State, animated: Bool, completion: (() -> Void)?)
    func willTransition(to state: State)
    func didTransition(to state: State)

    func shouldShowStatefulErrorView(for error: Error) -> Bool
    func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel
}

public extension StatefulViewController {
    func shouldShowStatefulErrorView(for error: Error) -> Bool {
        return true
    }
}

public extension StatefulViewController where Self: Reloadable {
    func viewModelForErrorState(_ error: Error) -> StatefulViewViewModel {
        return .init(message: error.localizedDescription,
                     ["Reload" => reload])
    }
}

private extension AssociatedObjectKeys {
    static let stateMachine = AssociatedObjectKey<ViewStateMachine>("stateMachine")
    static let logsStateTransitions = AssociatedObjectKey<Bool>("logsStateTransitions")
    static let initialState = AssociatedObjectKey<State>("initialState")
    static let onDidTransitionMixins = AssociatedObjectKey<[(State) -> Void]>("onDidTransitionMixins")
}

// MARK: Default Implementation StatefulViewController

extension StatefulViewController where Self: NSObject {
    public var stateMachine: ViewStateMachine {
        get {
            // swiftformat:disable:next redundantSelf
            return self[.stateMachine, self.createViewStateMachine()]
        }
        set {
            self[.stateMachine] = newValue
        }
    }

    public var logsStateTransitions: Bool {
        get {
            return self[.logsStateTransitions, false]
        }
        set {
            self[.logsStateTransitions] = newValue
        }
    }

    public var initialState: State? {
        get {
            return self[.initialState]
        }
        set {
            self[.initialState] = newValue
        }
    }

    public var onDidTransitionMixins: [(State) -> Void] {
        get {
            return self[.onDidTransitionMixins, []]
        }
        set {
            self[.onDidTransitionMixins] = newValue
        }
    }

    // MARK: Transitioning

    public func transitionToInitialState() {
        if currentState == .uninitialized {
            stateMachine.view = statefulSuperview
            transition(to: initialState ?? .initialized)
        }
    }
}

public extension StatefulViewController {
    func createViewStateMachine() -> ViewStateMachine {
        return ViewStateMachine(view: statefulSuperview, states: createStatefulViews())
    }

    var currentState: State {
        return stateMachine.currentState
    }

    var previousState: State {
        return stateMachine.previousState
    }

    func transition(to state: State, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.mainSyncSafe {
            self.willTransition(to: state)
            if self.logsStateTransitions {
                debugLog("\(String(describing: self)) Will transition to state: \(state)")
            }
            self.stateMachine.transition(to: state, completion: completion)

            self.didTransition(to: state)
            self.onDidTransitionMixins.forEach { $0(state) }
            if self.logsStateTransitions {
                debugLog("\(String(describing: self)) Did transition to: \(state)")
            }
        }
    }

    func transitionToErrorState(_ error: Error) {
        guard shouldShowStatefulErrorView(for: error) else {
            return
        }
        errorView()?.display(viewModelForErrorState(error))
        transition(to: .error)
    }

    func enforceCurrentState() {
        if logsStateTransitions {
            debugLog("\(String(describing: self)) Enforcing current state state: \(currentState)")
        }
        stateMachine.transition(to: currentState)
    }
}

// MARK: Default Stateful Views

extension StatefulViewController {
    public func loadingView() -> StatefulViewControllerDefaultLoadingView? {
        return stateMachine[.loading] as? StatefulViewControllerDefaultLoadingView
    }

    public func errorView() -> StatefulViewControllerView? {
        return stateMachine[.error] as? StatefulViewControllerView
    }

    public func emptyView() -> StatefulViewControllerView? {
        return stateMachine[.empty] as? StatefulViewControllerView
    }
}

extension StatefulViewController where Self: UIView {
    public var statefulSuperview: UIView {
        return self
    }

    public var logsStateTransitions: Bool {
        return false
    }
}

extension StatefulViewController where Self: UIViewController {
    public var statefulSuperview: UIView {
        return view
    }

    public var logsStateTransitions: Bool {
        return false
    }
}

public extension Array where Element: UIViewController {
    func transition(to state: State, animated: Bool = true, completion: VoidClosure? = nil) {
        for vc in self {
            if let statefulVC = vc as? StatefulViewController {
                statefulVC.transition(to: state, animated: animated, completion: completion)
            }
        }
    }
}

public class StatefulViewControllerMixin: UIViewControllerMixin<StatefulViewController> {
    open override func viewDidLoad() {
        mixable.customizeStatefulViews()
        loadInitialStateIfNeeded()
    }

    open func loadInitialStateIfNeeded() {
        if mixable.currentState == .uninitialized {
            mixable.transitionToInitialState()
        }
    }

//    open override func viewWillAppear(_ animated: Bool){
//        //In some cases, view did not update due to model state change in background
//        DispatchQueue.main.async {
//            self.mixable.enforceCurrentState()
//        }
//    }
}

public class StatefulViewMixin: UIViewMixin<StatefulViewController> {
    open override func didFinishCreatingAllViews() {
        mixable.customizeStatefulViews()
    }
}
