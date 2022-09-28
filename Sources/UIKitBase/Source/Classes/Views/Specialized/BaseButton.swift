//
//  BaseButton.swift
//  Pods
//
//  Created by Brian Strobach on 7/21/17.
//
//

import Layman
import Swiftest
import UIFontIcons
import UIKit
import UIKitExtensions
import UIKitTheme

// swiftlint:disable file_length

// MARK: Image heights are porportionate to button's frame, normalized between 0.0 and 1.0

public enum ButtonLayoutType {
    case centerTitleUnderImage(padding: CGFloat)
    case imageLeftTitleCenter
    case imageLeftTitleStackedRight(padding: CGFloat)
    case imageRightTitleCenter
    case imageRightTitleStackedLeft(padding: CGFloat)
    case imageAndTitleCentered(padding: CGFloat)
    case titleCentered
    case imageCentered
    case imageCenteredSquare
    case imageCenteredRound
}

public enum ButtonImageLayoutType {
    case square
    case stretchWidth
}

public func == (lhs: ButtonState, rhs: String) -> Bool {
    return lhs.rawValue == rhs
}

public func == (lhs: String, rhs: ButtonState) -> Bool {
    return lhs == rhs.rawValue
}

public enum ButtonState: State {
    case overrideAll
    case any
    case normal
    case selected
    case focused
    case tapped
    case disabled
    case activity
}

public typealias ButtonImageUrlMap = [ButtonState: URLConvertible]
public typealias ButtonImageMap = [ButtonState: UIImage]
public typealias ButtonAttributedTitleMap = [ButtonState: NSAttributedString]
public typealias ButtonTitleMap = [ButtonState: String]
public typealias ButtonStyleMap = [ButtonState: ButtonStyle]
public typealias ButtonTapActionMap = [ButtonState: VoidClosure]
public typealias ButtonIconMap<FontIcon: FontIconEnum> = [ButtonState: FontIcon]

open class ButtonLayout {
    public var layoutType: ButtonLayoutType
    public var imageLayoutType: ButtonImageLayoutType
    public var marginInsets: LayoutPadding
    public var imageInsets: LayoutPadding = .zero

    public init(layoutType: ButtonLayoutType = .imageLeftTitleCenter,
                imageLayoutType: ButtonImageLayoutType = .square,
                marginInsets: LayoutPadding? = nil,
                imageInsets: LayoutPadding? = nil)
    {
        self.layoutType = layoutType
        self.imageInsets =? imageInsets
        self.imageLayoutType = imageLayoutType
        guard let marginInsets = marginInsets else {
            switch layoutType {
            case .titleCentered:
                self.marginInsets = .zero
            default:
                self.marginInsets = LayoutPadding(10.0, 5.0)
            }
            return
        }
        self.marginInsets = marginInsets
    }
}

public enum ButtonDisableBehavior {
    case dropAlpha(to: CGFloat)
    //    case desaturate
}

public enum ButtonActivityBehavior {
    case removeTitle
    case showIndicator(style: UIActivityIndicatorView.Style, color: UIColor?, at: ActivityIndicatorPosition)
}

extension BaseButton: TextStyleable {
    public func apply(textStyle: TextStyle) {
        titleLabel.apply(textStyle: textStyle)
    }
}

// swiftlint:disable:next type_body_length
open class BaseButton: BaseView, ButtonStyleable {
    open var onTap: VoidClosure?
    open var adjustsFrameToFitContent: Bool = false
    open var tapRecognizer: UITapGestureRecognizer?
    open var contentLayoutView = UIView()
    open var titleLabel = UILabel()
    open var imageView = BaseImageView()
    open var tintsImagesToMatchTextColor: Bool = false {
        didSet {
            imageView.tintsImages = tintsImagesToMatchTextColor
        }
    }

    open lazy var buttonLayout = ButtonLayout()
    open var activityBehaviors: [ButtonActivityBehavior] = [.removeTitle, .showIndicator(style: .medium, color: nil, at: .center)]
    open var disabledBehaviors: [ButtonDisableBehavior] = [.dropAlpha(to: 0.5)]
    open var buttonTapActionMap: ButtonTapActionMap = [:]
    open var attributedTitleMap: ButtonAttributedTitleMap = [:] {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var titleMap: ButtonTitleMap = [:] {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var styleMap: ButtonStyleMap = [:] {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var imageMap: ButtonImageMap = [:] {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var imageUrlMap: ButtonImageUrlMap = [:] {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var state: ButtonState = .normal {
        didSet {
            if oldValue != state {
                previousState = oldValue
                stateDidChange()
            }
        }
    }

    open var previousState: ButtonState?

    open func stateDidChange() {
        self.applyCurrentStateConfiguration()
        self.additionalStateChangeActions()
    }

    open func additionalStateChangeActions() {
        if self.state == .disabled {
            self.applyDisabledStateBehaviors()
        } else if self.previousState == .disabled {
            self.removeDisabledStateBehaviors()
        }
        if self.state == .activity {
            self.applyActivityStateBehaviors()
        } else if self.previousState == .activity {
            self.removeActivityStateBehaviors()
        }
    }

    // MARK: Initialization

    public convenience init(frame: CGRect = .zero,
                            titles: ButtonTitleMap? = nil,
                            attributedTitles: ButtonAttributedTitleMap? = nil,
                            imageMap: ButtonImageMap? = nil,
                            imageUrlMap: ButtonImageUrlMap? = nil,
                            styleMap: ButtonStyleMap? = nil,
                            buttonLayout: ButtonLayout = ButtonLayout(),
                            onTap: VoidClosure? = nil)
    {
        self.init(callInitLifecycle: false)
        self.titleMap =? titles
        self.attributedTitleMap =? attributedTitles
        self.imageMap =? imageMap
        self.imageUrlMap =? imageUrlMap
        self.styleMap =? styleMap
        self.buttonLayout = buttonLayout
        self.onTap =? onTap
        initLifecycle(.programmatically)
    }

    public convenience init<T: FontIconEnum>(frame: CGRect = .zero, icon: T, style: ButtonStyle? = nil, buttonLayout: ButtonLayout? = nil, onTap: VoidClosure? = nil) {
        self.init(callInitLifecycle: false)
        let font = icon.getFont(style?.textStyle.font.pointSize ?? fontSize)
        if style?.textStyle.font.fontName != icon.fontName {
            style?.textStyle.font = font
        }

        self.styleMap[.any] = style ?? ButtonStyle(textStyle: TextStyle(color: .primaryContrast, font: font), viewStyle: ViewStyle())
        self.titleMap[.any] = icon.rawValue
        self.buttonLayout =? buttonLayout
        self.onTap =? onTap
        initLifecycle(.programmatically)
    }

    public convenience init(frame: CGRect = .zero, style: ButtonStyle, buttonLayout: ButtonLayout? = nil, onTap: VoidClosure? = nil) {
        self.init(callInitLifecycle: false)
        self.styleMap[.any] = style
        self.buttonLayout =? buttonLayout
        self.onTap =? onTap
        initLifecycle(.programmatically)
    }

    override public init(callInitLifecycle: Bool = true) {
        super.init(callInitLifecycle: callInitLifecycle)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        self.imageView.tintsImages = self.tintsImagesToMatchTextColor
        self.titleLabel.baselineAdjustment = .alignCenters
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.applyCurrentStateConfiguration()

        let tap = addTap { [weak self] view in
            guard let self = self else { return }
            self.buttonWasTapped(view: view)
        }
        tap.cancelsTouchesInView = false
    }

    open func buttonWasTapped<V: UIView>(view: V) {
        let action = self.buttonTapActionMap.firstValue(for: .overrideAll, self.state, .any) ?? self.onTap
        action?()
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubview(self.contentLayoutView)
        self.contentLayoutView.addSubviews([self.titleLabel, self.imageView])
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        self.apply(buttonLayout: self.buttonLayout)
    }

    // MARK: Touch handling, passing along touches when disabled

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.state == .disabled, self.buttonTapActionMap[.disabled] == nil {
            return false
        }
        if self.state == .activity, self.buttonTapActionMap[.activity] == nil {
            return false
        }
        return super.point(inside: point, with: event)
    }

    // TODO: Refactor this into a visitor pattern
    // swiftlint:disable:next function_body_length
    open func apply(buttonLayout: ButtonLayout) {
        self.contentLayoutView.forceSuperviewToMatchContentSize(insetBy: buttonLayout.marginInsets)

        switch buttonLayout.layoutType {
        case let .centerTitleUnderImage(padding):
            self.imageView.equal(to: self.contentLayoutView.top.inset(buttonLayout.imageInsets.top))
            self.imageView.insetOrEqual(to: self.contentLayoutView.horizontalEdges.inset(buttonLayout.imageInsets.horizontal))
            self.imageView.equal(to: self.contentLayoutView.centerX)
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType)

            self.titleLabel.enforceContentSize()
            self.titleLabel.equal(to: self.contentLayoutView.edges.excluding(.top))
            self.titleLabel.height.greaterThanOrEqual(to: 0)
            self.titleLabel.top.equal(to: self.imageView.bottom.plus(padding))
            self.titleLabel.textAlignment = .center

        case let .imageLeftTitleStackedRight(padding):
//            [imageView, titleLabel].stack(.leftToRight, in: contentLayoutView)
            self.imageView.equal(to: self.contentLayoutView.edges.excluding(.trailing).inset(buttonLayout.imageInsets))
            self.imageView.trailing.equal(to: self.titleLabel.leading.inset(padding))
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType)
            self.titleLabel.verticalEdges.equal(to: self.contentLayoutView)
            self.titleLabel.trailing.equal(to: self.contentLayoutView.trailing.inset(padding))
            self.titleLabel.textAlignment = .left
        case let .imageRightTitleStackedLeft(padding):
            self.imageView.equal(to: self.contentLayoutView.edges.excluding(.leading).inset(buttonLayout.imageInsets))
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType)
            self.titleLabel.verticalEdges.equal(to: self.contentLayoutView)
            self.titleLabel.leading.equal(to: self.contentLayoutView.leading.inset(padding))
            self.titleLabel.trailing.equal(to: self.imageView.leading.plus(padding))
            self.titleLabel.textAlignment = .right
        case .imageLeftTitleCenter:
            self.imageView.equal(to: self.contentLayoutView.edges.excluding(.trailing).inset(buttonLayout.imageInsets))
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)
            self.titleLabel.pinToSuperview()
            self.titleLabel.textAlignment = .center
        case .imageRightTitleCenter:
            self.imageView.equal(to: self.contentLayoutView.edges.excluding(.leading).inset(buttonLayout.imageInsets))
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)
            self.titleLabel.pinToSuperview()
            self.titleLabel.textAlignment = .center
        case .titleCentered:
            self.titleLabel.forceSuperviewToMatchContentSize()
            self.titleLabel.textAlignment = .center
        case .imageCentered:
            self.imageView.forceSuperviewToMatchContentSize(insetBy: buttonLayout.imageInsets)
            self.imageView.size.greaterThanOrEqual(to: 0.0)
        case .imageCenteredSquare:
            self.imageView.insetOrEqual(to: self.contentLayoutView.edges.inset(buttonLayout.imageInsets))
            self.imageView.centerInSuperview()
            self.imageView.size.greaterThanOrEqual(to: 0.0)
            self.imageView.aspectRatio.equal(to: .square)
        case .imageCenteredRound:
            self.imageView.insetOrEqual(to: self.contentLayoutView.edges.inset(buttonLayout.imageInsets))
            self.imageView.centerInSuperview()
            self.imageView.size.greaterThanOrEqual(to: 0.0)
            self.imageView.aspectRatio.equal(to: .square)
            self.imageView.rounded = true
        case let .imageAndTitleCentered(padding):

            self.imageView.enforceContentSize()
            self.imageView.equal(to: self.contentLayoutView.edges.excluding(.trailing).inset(buttonLayout.imageInsets))
            self.titleLabel.leading.equal(to: self.imageView.trailing.plus(padding + buttonLayout.imageInsets.trailing))
            self.createImageLayoutConstraints(for: self.imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)

            self.titleLabel.equal(to: self.contentLayoutView.verticalEdges)
            self.titleLabel.insetOrEqual(to: self.contentLayoutView.trailing)
            self.titleLabel.width.greaterThanOrEqual(to: 0)
            self.titleLabel.enforceContentSize()
            self.titleLabel.textAlignment = .center
        }
    }

    open func createImageLayoutConstraints(for imageView: UIImageView, ofType type: ButtonImageLayoutType, masterAttribute: NSLayoutConstraint.Attribute = .width) {
        switch type {
        case .square:
            if masterAttribute == .width {
                imageView.aspectRatioAnchor.equal(to: .square)
            } else {
                imageView.aspectRatioInverse.equal(to: .square)
            }
        case .stretchWidth:
            imageView.width.greaterThanOrEqual(to: imageView.height)
        }
    }

    open func applyCurrentStateConfiguration() {
        self.applyCurrentButtonStyle()
        self.applyCurrentImage()
        self.applyCurrentTitle()
    }

    open func applyCurrentTitle() {
        guard self.attributedTitleMap[.overrideAll] == nil else {
            self.titleLabel.attributedText = self.attributedTitleMap[.overrideAll]
            return
        }

        guard self.titleMap[.overrideAll] == nil else {
            self.titleLabel.text = self.titleMap[.overrideAll]
            return
        }

        if let attributedTitle = attributedTitleMap.firstValue(for: state, .any) {
            self.titleLabel.attributedText = attributedTitle
        } else if let title = titleMap.firstValue(for: state, .any) {
            self.titleLabel.text = title
        }
    }

    open func applyCurrentImage() {
        if self.tintsImagesToMatchTextColor {
            self.imageView.tintColor = self.titleLabel.textColor
        }

        if let imageUrl = imageUrlMap[.overrideAll]?.toURL {
            self.imageView.loadImage(with: imageUrl)
            return
        }

        if let image = imageMap[.overrideAll] {
            self.imageView.image = image
            return
        }

        if let imageUrl = imageUrlMap.firstValue(for: state, .any)?.toURL {
            self.imageView.loadImage(with: imageUrl)
        } else if let image = imageMap.firstValue(for: state, .any) {
            self.imageView.image = image
        }
    }

    public func setTitle(_ title: String?, for state: ButtonState = .any) {
        self.titleMap[state] = title
    }

    override open func style() {
        super.style()
        self.applyCurrentButtonStyle()
    }

    open func applyCurrentButtonStyle() {
        if let buttonStyle = styleMap.firstValue(for: .overrideAll, state, .any) {
            self.apply(buttonStyle: buttonStyle)
        }
    }

    internal var cachedAlpha: CGFloat?
    open func applyDisabledStateBehaviors() {
        for behavior in self.disabledBehaviors {
            switch behavior {
            case let .dropAlpha(value):
                self.cachedAlpha ??= alpha
                alpha = value
            }
        }
    }

    open func removeDisabledStateBehaviors() {
        for behavior in self.disabledBehaviors {
            switch behavior {
            case .dropAlpha:
                alpha =? self.cachedAlpha
                self.cachedAlpha = nil
            }
        }
    }

    internal var cachedTitleAlpha: CGFloat?
    open func applyActivityStateBehaviors() {
        for behavior in self.activityBehaviors {
            switch behavior {
            case .removeTitle:
                self.cachedTitleAlpha ??= self.titleLabel.alpha
                self.titleLabel.alpha = 0.0
            case let .showIndicator(style, color, position):
                showActivityIndicator(style: style, color: color, useAutoLayout: false, position: position)
            }
        }
    }

    open func removeActivityStateBehaviors() {
        for behavior in self.activityBehaviors {
            switch behavior {
            case .removeTitle:
                self.titleLabel.alpha =? self.cachedTitleAlpha
                self.cachedTitleAlpha = nil
            case .showIndicator:
                hideActivityIndicator()
            }
        }
    }
}

public extension BaseButton {
    var fontSize: CGFloat {
        set {
            if let font = titleLabel.font {
                self.titleLabel.font = font.withSize(newValue)
            } else {
                self.titleLabel.font = UIFont.systemFont(ofSize: newValue)
            }
        }
        get {
            return self.titleLabel.font.pointSize
        }
    }

    var fontName: String {
        set {
            self.titleLabel.font = UIFont(name: newValue, size: self.fontSize)
        }
        get {
            return self.titleLabel.font?.familyName ?? UIFont.systemFont(ofSize: self.fontSize).familyName
        }
    }

    // TODO: Improve this, rough calculation for usage in UIBarButtonItems
    func calculateMaxButtonSize() -> CGSize {
        let titleSize = self.titleMap.values.max()?.size(with: self.titleLabel.font) ?? CGSize.zero
        let imageSize = self.imageMap.values.max(by: { image1, image2 -> Bool in
            image1.size.width > image2.size.width
        })?.size ?? .zero
        var size = titleSize + imageSize
        size.height += (self.buttonLayout.marginInsets.top + self.buttonLayout.marginInsets.bottom + self.buttonLayout.imageInsets.top + self.buttonLayout.imageInsets.bottom)
        let widthMargins = (buttonLayout.marginInsets.leading + self.buttonLayout.marginInsets.trailing + self.buttonLayout.imageInsets.leading + self.buttonLayout.imageInsets.trailing)
        size.width += max(widthMargins, 15) // Magic number to avoid truncation
        return size
    }
}
