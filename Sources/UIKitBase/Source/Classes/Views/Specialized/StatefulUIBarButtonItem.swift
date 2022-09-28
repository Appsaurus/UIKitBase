//
//  StatefulUIBarButtonItem.swift
//  UIKitBase
//
//  Created by Brian Strobach on 2/13/22.
//

open class StatefulUIBarButtonItem<S: Hashable>: UIBarButtonItem{

    public typealias ButtonCyclerStateChangeCallback = (_ oldState: S, _ newState: S) -> Void

    open var stateCycleOrder: [S]? = nil
    open var onStateChange: ButtonCyclerStateChangeCallback?

    public class Configuration {

        public var style: ButtonStyle? = nil
        public var image: UIImage? = nil
        public var title: String? = nil
        public var action: (StatefulUIBarButtonItem<S>) -> () = {_ in }

        public init(style: ButtonStyle? = nil, image: UIImage? = nil, title: String? = nil, action: @escaping (StatefulUIBarButtonItem<S>) -> () = {_ in }) {
            self.style = style
            self.image = image
            self.title = title
            self.action = action
        }
    }

    open var currentState: S {
        didSet {
            didTransition(from: oldValue, to: currentState)
        }
    }

    open var states: [S : Configuration]

    open var globalStyle: ButtonStyle?

    open var currentConfiguration: Configuration {
        return self.states[self.currentState] ?? .init()
    }

    public required init(initialState: S, style: ButtonStyle? = nil,
                         states: [S : Configuration],
                         stateCycleOrder: [S]? = nil,
                         onStateChange: ButtonCyclerStateChangeCallback? = nil) {
        self.currentState = initialState
        self.globalStyle = style
        self.states = states
        self.onStateChange = onStateChange
        self.stateCycleOrder = stateCycleOrder ?? Array(states.keys)
        super.init()
        self.setupControlActions()
        self.applyCurrentStyle()

    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func applyCurrentStyle() {
        self.transitionTo(state: currentState)
    }

    open func setupControlActions() {
        self.addTargetAction { [weak self] in
            guard let `self` = self else { return }
            if self.onStateChange != nil {
                self.cycleToNextState()
            }
            else {
                self.didTapButton()
            }

        }
    }

    open func cycleToNextState() {
        guard let stateCycleOrder = self.stateCycleOrder,
              let index = stateCycleOrder.firstIndex(of: self.currentState) else { return }

        guard index != stateCycleOrder.lastIndex else {
            currentState = stateCycleOrder[0]
            return
        }
        currentState = stateCycleOrder[index + 1]
    }


    open func didTapButton() {
        currentConfiguration.action(self)
    }

    open func didTransition(from oldState: S, to newState: S){
        transitionLayout(from: oldState, to: newState)
        onStateChange?(oldState, newState)
    }

    open func transitionLayout(from oldState: S? = nil, to newState: S, animated: Bool = true) {

//        guard animated else {
        transitionTo(state: newState)
//            return
//        }

//        animate(animations: stateChanges)
    }

    open func transitionTo(state: S) {
        guard let config = self.states[state] else { return }
        self.title = config.title
        self.image = config.image
        if let tintColor = config.style?.textStyle.color ?? globalStyle?.textStyle.color {
            self.tintColor = tintColor
        }
    }
}
