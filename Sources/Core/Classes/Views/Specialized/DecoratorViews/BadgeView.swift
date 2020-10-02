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
        self.applyCurrentViewStyle()
    }

    @available(*, unavailable)
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
    open var label = UILabel()
    open var badgeHeight: CGFloat
    open var position: BadgeViewPosition
    open var badgeStyle: BadgeStyle {
        didSet {
            self.style()
        }
    }

    private var fontIconFont: UIFont? {
        didSet {
            self.style()
        }
    }

    private var fontSize: CGFloat? {
        didSet {
            self.style()
        }
    }

    public required init(position: BadgeViewPosition = .topRight, badgeHeight: CGFloat = 15.0, badgeStyle: BadgeStyle = .notification) {
        self.position = position
        self.badgeHeight = badgeHeight
        self.badgeStyle = badgeStyle
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.label)
        self.label.textAlignment = .center
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.label.pinToSuperview()
        height.equal(to: self.badgeHeight)
        width.greaterThanOrEqual(to: self.badgeHeight)
    }

    open var defaultFontSize: CGFloat {
        return badgeHeight * 0.6
    }

    override open func style() {
        super.style()
        let textStyle = App.style.badgeTextStyle(for: self.badgeStyle, fontSize: self.fontSize ?? self.defaultFontSize)
        if let iconFont = fontIconFont {
            textStyle.font = iconFont
        }
        self.label.apply(textStyle: textStyle)
        apply(viewStyle: App.style.badgeViewStyle(for: self.badgeStyle))
    }

    open func set(text: String, fontSize: CGFloat? = nil) {
        self.fontIconFont = nil
        self.fontSize = fontSize
        self.label.text = text
        self.style() // Adjusts font size to fit
    }

    open func set<FI: FontIconEnum>(icon: FI, fontSize: CGFloat? = nil) {
        self.label.setFontIconText(icon)
        self.fontSize = fontSize
        self.fontIconFont = icon.getFont(fontSize ?? self.defaultFontSize)
        self.style() // Adjusts font size to fit
    }
}
