//
//  StatefulViewControllerView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 7/13/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import Swiftest
import UIKit
import UIKitExtensions
import UIKitTheme

open class StatefulViewButtonViewModel {
    public var title: String
    public var action: VoidClosure
    public var style: ButtonStyle?

    public init(title: String, action: @escaping VoidClosure, style: ButtonStyle? = nil) {
        self.title = title
        self.action = action
        self.style = style
    }
}

open class StatefulViewViewModel {
    public var image: UIImage?
    public var imageURL: URLConvertible?
    public var headline: String?
    public var message: String?
    public var buttonViewModels: [StatefulViewButtonViewModel]
    
    public init(image: UIImage? = nil,
                imageURL: URLConvertible? = nil,
                headline: String? = nil,
                message: String? = nil,
                buttonViewModels: [StatefulViewButtonViewModel] = []) {
        self.image = image
        self.imageURL = imageURL
        self.headline = headline
        self.message = message
        self.buttonViewModels = buttonViewModels
    }
}
open class StatefulViewControllerView: BaseView {
    open lazy var stackView: UIStackView = UIStackView(stackViewConfiguration: defaultStackViewConfiguration, arrangedSubviews: initialArrangedSubviews())
    open lazy var defaultStackViewConfiguration: StackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .center, spacing: 15.0)

//    var viewModel: StatefulViewViewModel

    open func initialArrangedSubviews() -> [UIView] {
        var views: [UIView] = []

        return [messageLabel, responseButton]
    }

    open lazy var imageView = BaseImageView()
    open lazy var headlineLabel: UILabel = self.createLabel()
    open lazy var messageLabel: UILabel = self.createLabel()


    open func createLabel() -> UILabel {
        let label = UILabel()
        label.wrapWords()
        label.textAlignment = .center
        return label
    }

    open func createButton(_ viewModel: StatefulViewButtonViewModel) -> BaseUIButton {
        let button = BaseUIButton()
        
        return label
    }
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

    open func set(message: String) {
        messageLabel.text = message
    }

    open func set(message: String? = nil, responseButtonTitle: String? = nil, responseAction: VoidClosure? = nil) {
        if let message = message {
            messageLabel.text = message
        }
        if let buttonTitle = responseButtonTitle {
            responseButton.setTitle(buttonTitle, for: .normal)
        }

        if let responseAction = responseAction {
            self.responseAction = responseAction
        }
    }

    @discardableResult
    open func addButton(title: String, action: @escaping VoidClosure) -> BaseUIButton {
        let button = BaseUIButton()
        button.apply(buttonStyle: .flat(textStyle: .regular(color: .primary)))
        button.setTitle(title, for: .normal)
        button.addAction(action: action)
        stackView.addArrangedSubview(button)
        return button
    }

    open func didPressResponseButton() {
        responseAction?()
    }

    open override func style() {
        super.style()
        messageLabel.apply(textStyle: .regular())
        responseButton.apply(buttonStyle: .flat(textStyle: .regular(color: .primary)))
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil {
            backgroundColor = .white
        }
    }
}
