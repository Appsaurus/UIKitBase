//
//  StatefulUIButton.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/26/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import Foundation
import UIKitTheme


public class StatefulUIButton<S: Hashable>: BaseUIButton{

    public class Configuration {

        public var style: ButtonStyle? = nil
        public var image: UIImage? = nil
        public var title: String? = nil
        public var action: (StatefulUIButton<S>) -> () = {_ in }

        public init(style: ButtonStyle? = nil, image: UIImage? = nil, title: String? = nil, action: @escaping (StatefulUIButton<S>) -> () = {_ in }) {
            self.style = style
            self.image = image
            self.title = title
            self.action = action
        }
    }

    public var currentState: S {
        didSet {
            didTransition(from: oldValue, to: currentState)
        }
    }
    public var states: [S : Configuration]

    public var globalStyle: ButtonStyle?

    public var currentConfiguration: Configuration {
        return self.states[self.currentState] ?? .init()
    }

    public required init(initialState: S, style: ButtonStyle? = nil, states: [S : Configuration]) {
        self.currentState = initialState
        self.globalStyle = style
        self.states = states
        super.init(frame: .zero)
    }

    public override func style() {
        super.style()
        applyCurrentStyle()
    }

    public func applyCurrentStyle() {
        if let style = currentConfiguration.style ?? globalStyle {
            self.apply(buttonStyle: style)
        }
    }

    public override func setupControlActions() {
        super.setupControlActions()
        self.addAction { [weak self] in
            self?.didTapButton()
        }
    }


    func didTapButton() {
        currentConfiguration.action(self)
    }

    public func didTransition(from oldState: S, to newState: S){
        transitionLayout(from: oldState, to: newState)
    }

    public func transitionLayout(from oldState: S? = nil, to newState: S, animated: Bool = true) {
        let stateChanges = {  [weak self] in
            guard let self = self else { return }
            let config = self.currentConfiguration
            self.setTitle(config.title ?? "", forStates: [.normal])
            self.setImage(config.image, for: .normal)
            self.imageView?.image = self.currentConfiguration.image
            self.applyCurrentStyle()
        }
        guard animated else {
            stateChanges()
            return
        }
        animate(animations: stateChanges)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
