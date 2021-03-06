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
                _ buttonViewModels: [ButtonViewModelConvertible] = [])
    {
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
                      retry: VoidClosure? = nil) -> StatefulViewViewModel
    {
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
                      retry: VoidClosure? = nil) -> StatefulViewViewModel
    {
        var buttons: [ButtonViewModelConvertible] = []
        if let retry = retry {
            buttons.append(retryTitle => retry)
        }
        return .init("Error",
                     message: error.localizedDescription,
                     buttons)
    }
}

open class StatefulViewControllerView: BaseView, ViewModelBound {
    public enum Layout {
        case center
        case topCenter
    }

    public typealias Model = StatefulViewViewModel

    open lazy var stackView = UIStackView(stackViewConfiguration: defaultStackViewConfiguration)
    open lazy var defaultStackViewConfiguration = StackViewConfiguration.equalSpacingVertical(alignment: .center, spacing: 15.0)

    open lazy var imageView = BaseImageView()
    open lazy var headlineLabel: UILabel = self.createLabel()
    open lazy var messageLabel: UILabel = self.createLabel()
    open var layout: Layout

    public required init(viewModel: StatefulViewViewModel, layout: Layout = .topCenter) {
        self.layout = layout
        super.init(callInitLifecycle: false)
        bind(model: viewModel)
        initLifecycle()
    }

    @available(*, unavailable)
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

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.stackView)
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        let margin: LayoutConstant = 20
        switch self.layout {
        case .center:
            self.stackView.centerInSuperview()
            self.stackView.edgeAnchors.insetOrEqual(to: margins.edgeAnchors.inset(margin))
        case .topCenter:
            self.stackView.centerX.equalToSuperview()
            self.stackView.edgeAnchors.excluding(.top).insetOrEqual(to: margins.edgeAnchors.inset(margin))
            self.stackView.top.equal(to: margins.top.inset(margin))
        }

        self.stackView.sizeAnchors.greaterThanOrEqual(to: 0)
        self.stackView.arrangedSubviews.enforceContentSize()
        self.stackView.apply(stackViewConfiguration: self.defaultStackViewConfiguration)
    }

//    open override func didFinishCreatingAllViews() {
//        super.didFinishCreatingAllViews()
//        display(viewModel)
//    }

    open func display(model: StatefulViewViewModel) {
        var arrangedViews: [LayoutStackable] = []
        if let image = model.image {
            arrangedViews.append(self.imageView)
            _ = try? self.imageView.loadImage(image)
        }

        if let headline = model.headline {
            self.headlineLabel.text = headline
            arrangedViews.append(self.headlineLabel)
        }

        if let message = model.message {
            self.messageLabel.text = message
            arrangedViews.append(self.messageLabel)
        }

        arrangedViews += model.buttonViewModels.map { self.createButton($0) }
        self.stackView.stack(arrangedViews)
    }

    open func set(message: String) {
        self.messageLabel.text = message
    }

    open func set(message: String? = nil, responseButtonTitle: String? = nil, responseAction: VoidClosure? = nil) {
        if let message = message {
            self.messageLabel.text = message
        }
    }

    override open func style() {
        super.style()
        self.messageLabel.apply(textStyle: model.messageStyle ?? .regular())
        self.headlineLabel.apply(textStyle: model.headlineStyle ?? .displayHeadline(color: .primary))
        backgroundColor = App.style.statefulViewControllerViewBackgroundColor ?? parentViewController?.view.backgroundColor
        if backgroundColor == .clear || backgroundColor == nil {
            backgroundColor = .white
        }
    }
}
