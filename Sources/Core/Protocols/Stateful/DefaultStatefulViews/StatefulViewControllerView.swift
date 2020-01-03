//
//  StatefulViewControllerView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 7/13/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import Layman
import Swiftest
import UIKit
import UIKitExtensions
import UIKitTheme

open class StatefulViewViewModel {
    public var image: ImageResolving?
    public var headline: String?
    public var headlineStyle: TextStyle?
    public var message: String?
    public var messageStyle: TextStyle?
    public var buttonViewModels: [ButtonViewModel]

    public init(image: ImageResolving? = nil,
                _ headline: String? = nil,
                headlineStyle: TextStyle? = nil,
                message: String? = nil,
                messageStyle: TextStyle? = nil,
                _ buttonViewModels: [ButtonViewModelConvertible] = []) {
        self.image = image
        self.headline = headline
        self.headlineStyle = headlineStyle
        self.message = message
        self.messageStyle = messageStyle
        self.buttonViewModels = buttonViewModels.map { $0.toButtonViewModel() }
    }

    open class Defaults {}
}

extension StatefulViewViewModel {
    static func empty(headline: String = "No results",
                      retryTitle: String = "Reload",
                      retry: VoidClosure? = nil) -> StatefulViewViewModel {
        var buttons: [ButtonViewModelConvertible] = []
        if let retry = retry {
            buttons.append(retryTitle => retry)
        }
        return .init(headline,
                     buttons)
    }

    static var error: StatefulViewViewModel {
        return .init("Error")
    }

    static func error(_ error: Error,
                      retryTitle: String = "Reload",
                      retry: VoidClosure? = nil) -> StatefulViewViewModel {
        var buttons: [ButtonViewModelConvertible] = []
        if let retry = retry {
            buttons.append(retryTitle => retry)
        }
        return .init("Error",
                     message: error.localizedDescription,
                     buttons)
    }
}

open class StatefulViewControllerView: BaseView {
    open lazy var stackView: UIStackView = UIStackView(stackViewConfiguration: defaultStackViewConfiguration)
    open lazy var defaultStackViewConfiguration: StackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .center, spacing: 15.0)

    open var viewModel: StatefulViewViewModel

    open lazy var imageView = BaseImageView()
    open lazy var headlineLabel: UILabel = self.createLabel()
    open lazy var messageLabel: UILabel = self.createLabel()

    public required init(viewModel: StatefulViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func createLabel() -> UILabel {
        let label = UILabel()
        label.wrapWords()
        label.textAlignment = .center
        return label
    }

    open func createButton(_ viewModel: ButtonViewModel) -> BaseUIButton {
        let button = BaseUIButton()
        button.addAction(action: viewModel.action)
        let style = viewModel.style ?? .flat(textStyle: .regular(color: .primary))
        button.apply(buttonStyle: style)
        button.setTitle(viewModel.title, for: .normal)
        return button
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(stackView)
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.centerInSuperview()
        stackView.edgeAnchors.insetOrEqual(to: margins.edgeAnchors.inset(20))
        stackView.sizeAnchors.greaterThanOrEqual(to: 0)
        stackView.arrangedSubviews.enforceContentSize()
        stackView.apply(stackViewConfiguration: defaultStackViewConfiguration)
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        display(viewModel)
    }

    open func display(_ viewModel: StatefulViewViewModel) {
        var arrangedViews: [LayoutStackable] = []
        if let image = viewModel.image {
            arrangedViews.append(imageView)
            _ = try? imageView.loadImage(image)
        }

        if let headline = viewModel.headline {
            headlineLabel.text = headline
            arrangedViews.append(headlineLabel)
        }

        if let message = viewModel.message {
            messageLabel.text = message
            arrangedViews.append(messageLabel)
        }

        if arrangedViews.count > 0 {
            arrangedViews.append(UIStackView.Spacer.flexible)
        }

        arrangedViews += viewModel.buttonViewModels.map { self.createButton($0) }
        stackView.stack(arrangedViews)
    }

    open func set(message: String) {
        messageLabel.text = message
    }

    open func set(message: String? = nil, responseButtonTitle: String? = nil, responseAction: VoidClosure? = nil) {
        if let message = message {
            messageLabel.text = message
        }
    }

    open override func style() {
        super.style()
        messageLabel.apply(textStyle: viewModel.messageStyle ?? .regular())
        headlineLabel.apply(textStyle: viewModel.headlineStyle ?? .displayHeadline(color: .primary))
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil {
            backgroundColor = .white
        }
    }
}
