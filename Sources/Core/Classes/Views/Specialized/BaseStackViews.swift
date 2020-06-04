//
//  VerticalStackView.swift
//  Pods
//
//  Created by Brian Strobach on 7/19/17.
//
//

import UIKitExtensions

open class HorizontalStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        apply(stackViewConfiguration: .fillEquallyHorizontal(spacing: 10.0))
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

open class VerticalStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        apply(stackViewConfiguration: .equalSpacingVertical(spacing: 0.0))
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public protocol LazilyGrowingStackView {
    associatedtype StackedView: UIView
    var stackedViews: [StackedView] { get set }
    mutating func stackedView(at index: Int) -> StackedView
    func createStackedView() -> StackedView
}

var stackedViewsAssociated: UInt8 = 0

extension LazilyGrowingStackView where Self: UIStackView {
    public var stackedViews: [StackedView] {
        get {
            return getAssociatedObject(for: &stackedViewsAssociated, initialValue: [])
        }
        set {
            setAssociatedObject(newValue, for: &stackedViewsAssociated)
        }
    }

    public mutating func stackedView(at index: Int) -> StackedView {
        while self.stackedViews[safe: index] == nil {
            let view = createStackedView()
            stackedViews.append(view)
            view.enforceContentSize()
            addArrangedSubview(view)
        }
        return self.stackedViews[index]
    }
}

open class GrowingStackView<SV: UIView>: UIStackView, LazilyGrowingStackView {
    public func createStackedView() -> SV {
        return SV()
    }

    public typealias StackedView = SV
}

open class HorizontalButtonStackView: HorizontalStackView, LazilyGrowingStackView {
    public typealias StackedView = BaseButton
    open func createStackedView() -> BaseButton {
        return BaseButton(buttonLayout: ButtonLayout(layoutType: .titleCentered))
    }
}

open class VerticalButtonStackView: VerticalStackView, LazilyGrowingStackView {
    public typealias StackedView = BaseButton
    open func createStackedView() -> BaseButton {
        return BaseButton(buttonLayout: ButtonLayout(layoutType: .imageLeftTitleCenter))
    }
}

open class HorizontalLabelStackView: HorizontalStackView, LazilyGrowingStackView {
    public typealias StackedView = UILabel
    open func createStackedView() -> UILabel {
        return UILabel()
    }
}

open class VerticalLabelStackView: VerticalStackView, LazilyGrowingStackView {
    public typealias StackedView = UILabel
    open func createStackedView() -> UILabel {
        return UILabel()
    }
}
