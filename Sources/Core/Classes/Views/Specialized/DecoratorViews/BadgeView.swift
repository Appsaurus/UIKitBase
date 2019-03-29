//
//  BadgeView.swift
//  Pods
//
//  Created by Brian Strobach on 5/15/17.
//
//

import Swiftest
import UIFontIcons
import UIKitTheme

public enum BadgeViewPosition {
    case topRight
    case topRightInside
    case topLeft
    case topLeftInside
}

public enum BadgeStyle {
    case notification, warning, primary, primaryContrast, error, additive, delete
}

public protocol StatefulViewStyleable: ViewStyleable {
    associatedtype State: Hashable
    var viewStyleMap: ViewStyleMap { get set }
    var state: State { get set }
}

extension StatefulViewStyleable {
    public typealias ViewStyleMap = [State: ViewStyle]
}

open class StatefulBadgeView<S: Hashable>: BaseView, BadgeViewProtocol, StatefulViewStyleable {
    public typealias State = S
    open var position: BadgeViewPosition
    open var badgeHeight: CGFloat
    open var viewStyleMap: [State: ViewStyle] = [:]
    open var state: State {
        didSet {
            applyCurrentViewStyle()
        }
    }

    open func applyCurrentViewStyle() {
        guard let style = viewStyleMap[state] else { return }
        apply(viewStyle: style)
    }

    public required init(position: BadgeViewPosition = .topRight, badgeHeight: CGFloat = 15.0, state: S, viewStyleMap: ViewStyleMap? = nil) {
        self.position = position
        self.badgeHeight = badgeHeight
        self.viewStyleMap =? viewStyleMap
        self.state = state
        super.init(frame: .zero)
        applyCurrentViewStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol BadgeViewProtocol {
    var position: BadgeViewPosition { get set }
}

extension BadgeViewProtocol where Self: UIView {
    public func attachTo(view: UIView, in parentView: UIView? = nil) {
        let parent = parentView ?? view.superview ?? view
        parent.addSubview(self)
        switch position {
        case .topRight:
            centerXY.equal(to: view.topRight)
        case .topRightInside:
            topRight.equal(to: view.topRight)
        case .topLeft:
            centerXY.equal(to: view.topLeft)
        case .topLeftInside:
            topLeft.equal(to: view.topLeft)
        }
        moveToFront()
    }
}

open class BadgeView: BaseView, BadgeViewProtocol {
    open var label: UILabel = UILabel()
    open var badgeHeight: CGFloat
    open var position: BadgeViewPosition
    open var badgeStyle: BadgeStyle {
        didSet {
            style()
        }
    }

    private var fontIconFont: UIFont? {
        didSet {
            style()
        }
    }

    private var fontSize: CGFloat? {
        didSet {
            style()
        }
    }

    public required init(position: BadgeViewPosition = .topRight, badgeHeight: CGFloat = 15.0, badgeStyle: BadgeStyle = .notification) {
        self.position = position
        self.badgeHeight = badgeHeight
        self.badgeStyle = badgeStyle
        super.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(label)
        label.textAlignment = .center
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        label.pinToSuperview()
        height.equal(to: badgeHeight)
        width.greaterThanOrEqual(to: badgeHeight)
    }

    open var defaultFontSize: CGFloat {
        return badgeHeight * 0.6
    }

    open override func style() {
        super.style()
        let textStyle = App.style.badgeTextStyle(for: badgeStyle, fontSize: fontSize ?? defaultFontSize)
        if let iconFont = fontIconFont {
            textStyle.font = iconFont
        }
        label.apply(textStyle: textStyle)
        apply(viewStyle: App.style.badgeViewStyle(for: badgeStyle))
    }

    open func set(text: String, fontSize: CGFloat? = nil) {
        fontIconFont = nil
        self.fontSize = fontSize
        label.text = text
        style() // Adjusts font size to fit
    }

    open func set<FI: FontIconEnum>(icon: FI, fontSize: CGFloat? = nil) {
        label.setFontIconText(icon)
        self.fontSize = fontSize
        fontIconFont = icon.getFont(fontSize ?? defaultFontSize)
        style() // Adjusts font size to fit
    }
}
