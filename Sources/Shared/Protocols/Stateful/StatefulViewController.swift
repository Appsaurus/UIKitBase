//
//  StatefulViewController.h
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 11/5/15.
//  Copyright Â© 2016 Appsaurus. All rights reserved.
//

import UIKit
import Swiftest
import UIKitMixinable
import DarkMagic

public typealias State = String

extension State{
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

extension Dictionary where Key == State, Value == UIView{
    public static var `default`: StatefulViewMap {
        return StatefulViewControllerDefaults.defaultStatefulViews()
    }
}

public class StatefulViewControllerDefaults{
    public static var defaultStatefulViews: () -> StatefulViewMap = {
        return [.empty : StatefulViewControllerEmptyView(frame: .zero),
                .loading : StatefulViewControllerDefaultLoadingView(frame: .zero),
                .error : StatefulViewControllerErrorView(frame: .zero)]
    }
}
public protocol StatefulViewController: class {
    var statefulSuperview: UIView { get }
    var stateMachine: ViewStateMachine { get set }
    var logsStateTransitions: Bool{ get set }
    
    // Hook to insert custom logic for first load instead of viewDidLoad.
    // Does not apply to UIViews that adopt protocol.
    func startLoading()
    
    func statefulViewControllerDidLoad()
    func createViewStateMachine() -> ViewStateMachine
    func customizeStatefulViews()
    func createStatefulViews() -> StatefulViewMap
    
    func transitionToInitialState()
    
    
    // MARK: Transitions
    func transition(to state: State, animated: Bool, completion: (() -> ())?)
    func willTransition(to state: State)
    func didTransition(to state: State)
}



private extension AssociatedObjectKeys{
    static let stateMachine = AssociatedObjectKey<ViewStateMachine>("stateMachine")
    static let logsStateTransitions = AssociatedObjectKey<Bool>("logsStateTransitions")
    static let initialState = AssociatedObjectKey<State>("initialState")
}

// MARK: Default Implementation StatefulViewController
extension StatefulViewController where Self: NSObject{
    
    public var stateMachine: ViewStateMachine{
        get{
            return getAssociatedObject(for: .stateMachine, initialValue: self.createViewStateMachine())
        }
        set{
            setAssociatedObject(newValue, for: .stateMachine)
        }
    }
    
    public var logsStateTransitions: Bool{
        get{
            return getAssociatedObject(for: .logsStateTransitions, initialValue: false)
        }
        set{
            setAssociatedObject(newValue, for: .logsStateTransitions)
        }
    }
    
    public var initialState: State?{
        get{
            
            return getAssociatedObject(for: .initialState)
        }
        set{
            setAssociatedObject(newValue, for: .initialState)
        }
    }
    
    //MARK: Transitioning
    public func transitionToInitialState(){
        if currentState == .uninitialized{
            stateMachine.view = self.statefulSuperview
            transition(to: initialState ?? .initialized)
        }
    }
}

extension StatefulViewController{
    
    public func createViewStateMachine() -> ViewStateMachine{
        return ViewStateMachine(view: self.statefulSuperview, states: self.createStatefulViews())
    }
    
    public var currentState: State {
        return stateMachine.currentState
    }
    
    public var previousState: State {
        return stateMachine.previousState
    }

    public func setupStatefulViews(){
        customizeStatefulViews()
    }
    
    public func statefulViewControllerDidLoad(){
        setupStatefulViews()
        loadIfNeeded()
    }
    
    
    public func loadIfNeeded(){
        if currentState == .uninitialized{
            transitionToInitialState()
            startLoading()
        }
    }
    
    
    public func transition(to state: State, animated: Bool = true, completion: (() -> ())? = nil){
        
        DispatchQueue.mainSyncSafe {
            self.willTransition(to: state)
            if self.logsStateTransitions{
                debugLog("\(String(describing: self)) Will transition to state: \(state)")
            }
            self.stateMachine.transition(to: state, completion: completion)
            
            self.didTransition(to: state)
            
            if self.logsStateTransitions{
                debugLog("\(String(describing: self)) Did transition to: \(state)")
            }
        }
        
    }
}

//MARK: Default Stateful Views
extension StatefulViewController{
    
    public func loadingView() -> StatefulViewControllerDefaultLoadingView? {
        return stateMachine[.loading] as? StatefulViewControllerDefaultLoadingView
    }
    
    public func errorView() -> StatefulViewControllerErrorView? {
        return stateMachine[.error] as? StatefulViewControllerErrorView
    }
    
    public func emptyView() -> StatefulViewControllerEmptyView? {
        return stateMachine[.empty] as? StatefulViewControllerEmptyView
    }
}


extension StatefulViewController where Self:  UIView{
    public var statefulSuperview: UIView{
        return self
    }
    public var logsStateTransitions: Bool{
        return false
    }
    
    public func startLoading(){
        
    }
}
extension StatefulViewController where Self: UIViewController {
    
    public var statefulSuperview: UIView {
        return view
    }
    
    public var logsStateTransitions: Bool{
        return false
    }
}

public extension Array where Element: UIViewController{
    public func transition(to state: State, animated: Bool = true, completion: VoidClosure? = nil){
        for vc in self{
            if let statefulVC = vc as? StatefulViewController{
                statefulVC.transition(to: state, animated: animated, completion: completion)
            }
        }
    }
}


public class StatefulViewControllerMixin: UIViewControllerMixin<StatefulViewController>{
    open override func viewDidLoad() {
        mixable.statefulViewControllerDidLoad()
    }
//    @objc open func viewWillAppear(_ animated: Bool) {
//        mixable.statefulViewControllerWillAppear()
//    }
}
public class StatefulViewMixin: UIViewMixin<StatefulViewController>{
    open override func didFinishCreatingAllViews(){
        mixable.setupStatefulViews()
    }
}
