//
//  ViewStateMachine.swift
//  StatefulViewController
//
//  Created by Alexander Schuch on 30/07/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

import UIKit

///
/// A state machine that manages a set of views.
///
/// There are two possible states:
///        * Show a specific placeholder view, represented by a key
///        * Hide all managed views
///
@objc public class ViewStateMachine: NSObject {
    private var viewStore: [State: UIView]
    private let queue = DispatchQueue(label: "com.uiKitBase.viewStateMachine.queue", attributes: .concurrent)

    /// The view that should act as the superview for any added views
    public var view: UIView

    public private(set) var currentState: State = .uninitialized

    public private(set) var previousState: State = .uninitialized

    // MARK: Init

    ///  Designated initializer.
    ///
    /// - parameter view:        The view that should act as the superview for any added views
    /// - parameter states:        A dictionary of states
    ///
    /// - returns:            A view state machine with the given views for states
    ///
    public init(view: UIView, states: [State: UIView]?) {
        self.view = view
        viewStore = states ?? [State: UIView]()
    }

    /// - parameter view:        The view that should act as the superview for any added views
    ///
    /// - returns:            A view state machine
    ///
    public convenience init(view: UIView) {
        self.init(view: view, states: nil)
    }

    // MARK: Add and remove view states

    /// - returns: the view for a given state
    public func viewForState(state: State) -> UIView? {
        return viewStore[state]
    }

    /// Associates a view for the given state
    public func addView(view: UIView, forState state: State) {
        viewStore[state] = view
    }

    ///  Removes the view for the given state
    public func removeViewForState(state: State) {
        viewStore[state] = nil
    }

    // MARK: Subscripting

    public subscript(state: State) -> UIView? {
        get {
            return viewForState(state: state)
        }
        set(newValue) {
            if let value = newValue {
                addView(view: value, forState: state)
            } else {
                removeViewForState(state: state)
            }
        }
    }

    // MARK: Switch view state

    /// Adds and removes views to and from the `view` based on the given state.
    /// Animations are synchronized in order to make sure that there aren't any animation gliches in the UI
    ///
    /// - parameter state:        The state to transition to
    /// - parameter animated:    true if the transition should fade views in and out
    /// - parameter completion:    called when all animations are finished and the view has been updated
    ///
    public func transition(to state: State, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if state == self.currentState {
                if let statefulView = self.viewForState(state: state) {
                    statefulView.superview?.bringSubviewToFront(statefulView)
                    completion?()
                }
                else {
                    self.hideAllViews(animated: animated, completion: completion)
                }
                return
            }

            self.previousState = self.currentState
            self.currentState = state
        // Update the view

            if let statefulView = self.viewForState(state: state) {
                self.show(statefulView: statefulView, for: state, animated: animated, completion: completion)
            } else {
                self.hideAllViews(animated: animated, completion: completion)
            }
        }
    }

    // MARK: Private view updates

    public func show(statefulView: UIView, for state: State, animated: Bool, completion: (() -> Void)? = nil) {
//        if let previousView = self.viewForState(state: previousState) {
//            previousView.removeFromSuperview()
//        }
        self.hideAllViews(animated: animated)

        let parentView = view // is UIScrollView ? view.superview ?? view : view //Adding to scrollview will not have desired behavior, so add to parent and pin to view.

        statefulView.frame = parentView.bounds
        parentView.addSubview(statefulView)
        if parentView is UIScrollView {
            statefulView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        } else {
            statefulView.edges.equal(to: parentView.edges)
        }
        parentView.bringSubviewToFront(statefulView)
        completion?()
    }

    public func hideAllViews(animated: Bool, completion: (() -> Void)? = nil) {
        for (_, view) in viewStore {
            view.removeFromSuperview()
        }
        completion?()
    }
}
