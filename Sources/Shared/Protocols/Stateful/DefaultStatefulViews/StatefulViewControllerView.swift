//
//  StatefulViewControllerView.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 7/13/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import UIKit
import Swiftest
import UIKitExtensions
import UIKitTheme

open class StatefulViewControllerView: BaseView {
    
    open lazy var stackView: UIStackView = UIStackView(stackViewConfiguration: defaultStackViewConfiguration, arrangedSubviews: initialArrangedSubviews())
	open lazy var defaultStackViewConfiguration: StackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .center, spacing: 15.0)
    
    open func initialArrangedSubviews() -> [UIView]{
        return [mainLabel, responseButton]
    }
    
    open lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.wrapWords()
        label.textAlignment = .center
        return label
    }()
    open var responseButton: BaseUIButton = BaseUIButton()
    public var responseAction: VoidClosure?
    
    open override func setupControlActions() {
        super.setupControlActions()
        responseButton.addAction(action: didPressResponseButton)
    }
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
		stackView.apply(stackViewConfiguration: defaultStackViewConfiguration)
    }
    
    open override func createSubviews() {
        super.createSubviews()
        addSubview(stackView)
    }
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
		stackView.centerInSuperview()
        stackView.edgeAnchors.insetOrEqual(to: edgeAnchors)
        stackView.sizeAnchors.greaterThanOrEqual(to: 0)

    }
    open func set(message: String){
        mainLabel.text = message
    }
    
    open func set(message: String? = nil, responseButtonTitle: String? = nil, responseAction: VoidClosure? = nil){
        if let message = message{
            mainLabel.text = message
        }
        if let buttonTitle = responseButtonTitle{
            responseButton.setTitle(buttonTitle, for: .normal)
        }
        
        if let responseAction = responseAction{
            self.responseAction = responseAction
        }
        
    }
    
    @discardableResult
    open func addButton(title: String, action: @escaping VoidClosure) -> BaseUIButton{
        let button = BaseUIButton()
		button.apply(buttonStyle: .flat(textStyle: .regular(color: .primary)))
        button.setTitle(title, for: .normal)
        button.addAction(action: action)
        stackView.addArrangedSubview(button)
        return button
    }
    
    open func didPressResponseButton(){
        responseAction?()
    }
    
    open override func style() {
        super.style()
        mainLabel.apply(textStyle: .regular())
		responseButton.apply(buttonStyle: .flat(textStyle: .regular(color: .primary)))
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? self.parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil{
            backgroundColor = .white
        }
    }
    
    
}

