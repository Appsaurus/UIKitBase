//
//  ButtonViewModel.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/2/20.
//

import Actions
import UIKitExtensions
import UIKitTheme

public func .~ (lhs: TitledAction, rhs: ButtonStyle) -> ButtonViewModel {
    return ButtonViewModel(title: lhs.title, action: lhs.action, style: rhs)
}

open class ButtonViewModel: TitledAction {
    public var style: ButtonStyle?

    public convenience init(title: String, action: @escaping () -> Void, style: ButtonStyle?) {
        self.init(title: title, action: action)
        self.style = style
    }
}

public extension UIButton {
    @discardableResult
    func apply(viewModel: ButtonViewModel) -> UIButton {
        setTitle(viewModel.title, for: .normal)
        addAction(action: viewModel.action)
        if let style = viewModel.style {
            apply(buttonStyle: style)
        }
        return self
    }
}

public extension BaseButton {
    @discardableResult
    func apply(viewModel: ButtonViewModel) -> BaseButton {
        setTitle(viewModel.title, for: .normal)
        addAction(action: viewModel.action)
        if let style = viewModel.style {
            apply(buttonStyle: style)
        }
        return self
    }
}

public protocol ButtonViewModelConvertible {
    func toButtonViewModel() -> ButtonViewModel
}

extension TitledAction: ButtonViewModelConvertible {
    public func toButtonViewModel() -> ButtonViewModel {
        return ButtonViewModel(title: title, action: action)
    }
}
