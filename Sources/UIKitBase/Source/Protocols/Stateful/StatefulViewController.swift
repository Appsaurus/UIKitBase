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

public extension State {
    static let uninitialized = "uninitialized"
    static let initialized = "initialized"
    static let loaded = "loaded"
    static let loading = "loading"
    static let refreshing = "refreshing"
    static let refreshingError = "refreshingError"
    static let error = "error"
    static let empty = "empty"
    static let loadingMore = "loadingMore"
    static let loadedAll = "loadedAll"
    static let loadMoreError = "loadMoreError"
}

public typealias StatefulViewMap = [State: UIView]

public extension Dictionary where Key == State, Value == UIView {
    static func `default`(for statefulViewController: StatefulViewController) -> StatefulViewMap {
        return StatefulViewControllerDefaults.statefulViews(statefulViewController)
    }
}

public enum StatefulViewControllerDefaults {
    public static var statefulViews: (StatefulViewController) -> StatefulViewMap = { vc in
        let weakRetry: VoidClosure = { [weak vc] in
            vc?.reload()
        }
        return [.empty: StatefulViewControllerView(viewModel: .empty(retry: weakRetry)),
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

public extension StatefulViewController {
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

public extension StatefulViewController where Self: NSObject {
    var stateMachine: ViewStateMachine {
        get {
            // swiftformat:disable:next redundantSelf
            return self[.stateMachine, self.createViewStateMachine()]
        }
        set {
            self[.stateMachine] = newValue
        }
    }

    var logsStateTransitions: Bool {
        get {
            return self[.logsStateTransitions, false]
        }
        set {
            self[.logsStateTransitions] = newValue
        }
    }

    var initialState: State? {
        get {
            return self[.initialState]
        }
        set {
            self[.initialState] = newValue
        }
    }

    var onDidTransitionMixins: [(State) -> Void] {
        get {
            return self[.onDidTransitionMixins, []]
        }
        set {
            self[.onDidTransitionMixins] = newValue
        }
    }

    // MARK: Transitioning

    func transitionToInitialState() {
        if currentState == .uninitialized {
            self.stateMachine.view = statefulSuperview
            transition(to: self.initialState ?? .initialized)
        }
    }
}

public extension StatefulViewController {
    func createViewStateMachine() -> ViewStateMachine {
        return ViewStateMachine(view: statefulSuperview, states: createStatefulViews())
    }

    var currentState: State {
        return self.stateMachine.currentState
    }

    var previousState: State {
        return self.stateMachine.previousState
    }

    func transition(to state: State, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
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
        guard self.shouldShowStatefulErrorView(for: error) else {
            return
        }
        errorView?.bind(model: self.viewModelForErrorState(error))
        self.transition(to: .error)
    }

    func enforceCurrentState() {
        if self.logsStateTransitions {
            debugLog("\(String(describing: self)) Enforcing current state state: \(self.currentState)")
        }
        self.stateMachine.transition(to: self.currentState)
    }
}

// MARK: Default Stateful Views

public extension StatefulViewController {
    var loadingView: StatefulViewControllerDefaultLoadingView? {
        return self.stateMachine[.loading] as? StatefulViewControllerDefaultLoadingView
    }

    var errorView: StatefulViewControllerView? {
        return self.stateMachine[.error] as? StatefulViewControllerView
    }

    var emptyView: StatefulViewControllerView? {
        return self.stateMachine[.empty] as? StatefulViewControllerView
    }
}

public extension StatefulViewController where Self: UIView {
    var statefulSuperview: UIView {
        return self
    }

    var logsStateTransitions: Bool {
        return false
    }
}

public extension StatefulViewController where Self: UIViewController {
    var statefulSuperview: UIView {
        return view
    }

    var logsStateTransitions: Bool {
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
    override open func viewDidLoad() {
        mixable?.customizeStatefulViews()
        self.loadInitialStateIfNeeded()
    }

    open func loadInitialStateIfNeeded() {
        if mixable?.currentState == .uninitialized {
            mixable?.transitionToInitialState()
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
    override open func didFinishCreatingAllViews() {
        mixable?.customizeStatefulViews()
    }
}
