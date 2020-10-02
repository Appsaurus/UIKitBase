//
//  MaterialTextField.swift
//  Pods
//
//  Created by Brian Strobach on 9/12/17.
//
//

import DarkMagic
import Layman
import Swiftest
import UIKitExtensions
import UIKitTheme

open class MaterialTextField: AnimatableTextField {
    open var underlineView = UIView()
    open var placeholderActiveScale: CGFloat = 0.7

    override open var placeholder: String? {
        set {
            _internalPlaceholder = newValue
        }
        get {
            return super.placeholder
        }
    }

    open var _internalPlaceholder: String? {
        didSet {
            displayPlaceholderIfNeeded()
        }
    }

    open func displayPlaceholderIfNeeded() {
        guard let placeholder = _internalPlaceholder, currentState == .active else {
            super.placeholder = nil
            return
        }
        super.placeholder = placeholder
    }

    open var title: String? {
        didSet {
            titleLabel.text = title
            applyCurrentStateConfiguration()
        }
    }

    open var hintText: String? {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var errorText: String? {
        didSet {
            applyCurrentStateConfiguration()
        }
    }

    open var secondaryText: String? {
        return errorText ?? hintText
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard styleMap.keys.count == 0, let parentColor = firstVisibleParentBackgroundColor else {
            return
        }
        styleMap = .materialStyleMap(contrasting: parentColor)
    }

    override open func createSubviews() {
        super.createSubviews()
        addSubviews([titleLabel, secondaryLabel, self.underlineView])
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        secondaryLabel.equal(to: edges.excluding(.top))
        secondaryLabel.height.equal(to: layoutHeights.secondaryLabel)
        self.underlineView.horizontalEdges.equal(to: horizontalEdges)
        self.underlineView.bottom.equal(to: bottom.inset(layoutHeights.secondaryLabel))
        self.underlineView.height.equal(to: 2.0)
        height.equal(to: layoutHeights.titleLabel + layoutHeights.textField + layoutHeights.secondaryLabel)
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard currentState == .disabled else { return }
        let dotColor = (styleMap[.disabled] as? MaterialTextFieldStyle)?.underlineViewStyle.backgroundColor
        self.underlineView.backgroundColor = nil
        DrawingUtils.drawDottedUnderline(strokeColor: dotColor, in: self.underlineView)
    }

    override open func apply(textFieldStyle: TextFieldStyle) {
        super.apply(textFieldStyle: textFieldStyle)
        guard let materialStyle = textFieldStyle as? MaterialTextFieldStyle else { return }
        self.underlineView.apply(viewStyle: materialStyle.underlineViewStyle)
        titleLabel.apply(textStyle: materialStyle.titleLabelTextStyle)
        secondaryLabel.apply(textStyle: materialStyle.secondaryLabelTextStyle)
    }

    override open func applyCurrentStateConfiguration(animated: Bool = false) {
        super.applyCurrentStateConfiguration(animated: animated)
        self.displayPlaceholderIfNeeded()
        self.displayTitleLabelIfNeeded()
        self.updateSecondaryLabel()
    }

    open func displayTitleLabelIfNeeded(animated: Bool = true) {
        guard self.title.hasNonEmptyValue else {
            titleLabel.alpha = 0.0
            return
        }

        titleLabel.alpha = 1.0
    }

    open func showSecondaryLabel(animated: Bool = true) {
        secondaryLabel.animateConstraintChanges({ [weak self] in
            self?.secondaryLabel.constraint(for: .bottom)?.constant = 0
        }, configuration: labelAnimationConfiguration, additionalAnimations: { [weak self] in
            self?.secondaryLabel.alpha = 1.0
        })
    }

    open func hideSecondaryLabel(animated: Bool = true) {
        secondaryLabel.animateConstraintChanges({ [weak self] in
            guard let self = self else { return }
            self.secondaryLabel.constraint(for: .bottom)?.constant = -self.secondaryLabel.frame.h
        }, configuration: labelAnimationConfiguration, additionalAnimations: { [weak self] in
            self?.secondaryLabel.alpha = 0.0
        })
    }

    open func updateSecondaryLabel(animated: Bool = true) {
        secondaryLabel.text = self.secondaryText
        guard self.secondaryText.hasNonEmptyValue else {
            //  hideSecondaryLabel(animated: animated)
            return
        }
        // secondaryLabel.text = secondaryText
        // showSecondaryLabel(animated: animated)
    }

    open var shouldPositionAbove: Bool {
        let hasValue = text.hasNonEmptyValue
        let positionAbove = hasValue || currentState == .active
        return positionAbove
    }

    override open func layoutTitleLabel() {
        // let insetX = leftViewWidth + textInset

        titleLabel.layer.anchorPoint = .zero

        guard self.shouldPositionAbove else {
            titleLabel.transform = CGAffineTransform.identity
            titleLabel.frame = textRect(forBounds: bounds.height == 0 ? CGRect(x: 0, y: 0, width: frame.w, height: frame.h) : bounds)
            return
        }

        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.w, height: layoutHeights.titleLabel)
        titleLabel.transform = CGAffineTransform(scaleX: self.placeholderActiveScale, y: self.placeholderActiveScale)
    }
}

open class MaterialTextFieldStyle: TextFieldStyle {
    open var underlineViewStyle: ViewStyle
    open var titleLabelTextStyle: TextStyle
    open var secondaryLabelTextStyle: TextStyle

    public init(textStyle: TextStyle,
                viewStyle: ViewStyle = ViewStyle(),
                underlineViewStyle: ViewStyle? = nil,
                titleLabelTextStyle: TextStyle? = nil,
                secondaryLabelTextStyle: TextStyle? = nil)
    {
        let titleLabelTextStyle = titleLabelTextStyle ?? textStyle
        let underlineViewStyle = underlineViewStyle ?? ViewStyle(backgroundColor: titleLabelTextStyle.color)
        let secondaryLabelTextStyle = secondaryLabelTextStyle ?? {
            let defaultSecondary = titleLabelTextStyle.copy()
            defaultSecondary.font = defaultSecondary.font.withSize(defaultSecondary.font.pointSize - 4.0)
            return defaultSecondary
        }()
        self.titleLabelTextStyle = titleLabelTextStyle
        self.underlineViewStyle = underlineViewStyle
        self.secondaryLabelTextStyle = secondaryLabelTextStyle
        super.init(textStyle: textStyle, viewStyle: viewStyle)
    }
}

private extension AssociatedObjectKeys {
    static let materialTextFieldStyle = AssociatedObjectKey<MaterialTextFieldStyle>("materialTextFieldStyle")
    static let materialTextFieldMap = AssociatedObjectKey<TextFieldStyleMap>("materialTextFieldMap")
}

extension TextFieldStyleDefaults {
    open var materialTextFieldStyle: MaterialTextFieldStyle {
        get {
            return self[.materialTextFieldStyle, MaterialTextFieldStyle(textStyle: self.text.regular())]
        }
        set {
            self[.materialTextFieldStyle] = newValue
        }
    }

    open var materialTextFieldMap: TextFieldStyleMap {
        get {
            return self[.materialTextFieldMap, self.textField.materialStyleMap(color: .textDark, titleColor: .textMediumLight)]
        }
        set {
            self[.materialTextFieldMap] = newValue
        }
    }
}

extension TextFieldStyleGuide {
    open func materialStyleMap(color: UIColor? = nil,
                               titleColor: UIColor? = nil,
                               disabledColor: UIColor? = nil,
                               textSize: CGFloat = 16.0,
                               secondarySize: CGFloat = 12.0) -> TextFieldStyleMap
    {
        let color = color ?? colors.primary
        let titleColor = titleColor ?? color

        let inactive = text.regular(color: color.adjustedAlpha(amount: -0.2), size: textSize)
        let inactiveTitle = text.regular(color: titleColor.adjustedAlpha(amount: -0.2), size: textSize)
        let inactiveSmall = text.regular(color: colors.functional.error, size: secondarySize)

        let active = text.bold(color: color, size: textSize)
        let activeTitle = text.bold(color: titleColor, size: textSize)
        let activeSmall = text.bold(color: colors.functional.error, size: secondarySize)

        let alphaAdjust: CGFloat = -0.4
        let disabledColor = disabledColor ?? titleColor.adjustedAlpha(amount: alphaAdjust)
        let disabled = text.regular(color: disabledColor, size: textSize)
        let disabledTitle = text.regular(color: disabledColor, size: textSize)
        let disabledSmall = text.regular(color: colors.functional.error.adjustedAlpha(amount: alphaAdjust), size: secondarySize)

        return [
            .inactive: MaterialTextFieldStyle(textStyle: inactive,
                                              titleLabelTextStyle: inactiveTitle,
                                              secondaryLabelTextStyle: inactiveSmall),
            .active: MaterialTextFieldStyle(textStyle: active,
                                            titleLabelTextStyle: activeTitle,
                                            secondaryLabelTextStyle: activeSmall),
            .disabled: MaterialTextFieldStyle(textStyle: disabled,
                                              titleLabelTextStyle: disabledTitle,
                                              secondaryLabelTextStyle: disabledSmall),
            .readOnly: MaterialTextFieldStyle(textStyle: active,
                                              underlineViewStyle: ViewStyle(backgroundColor: .clear),
                                              titleLabelTextStyle: activeTitle,
                                              secondaryLabelTextStyle: activeSmall)
        ]
    }
}

public protocol T {}
extension TextFieldState: T {}
extension Dictionary where Key: T, Value: TextFieldStyle {
    public static func materialStyleMap(color: UIColor? = nil,
                                        titleColor: UIColor? = nil,
                                        disabledColor: UIColor? = nil,
                                        textSize: CGFloat = 16.0,
                                        secondarySize: CGFloat = 12.0) -> TextFieldStyleMap
    {
        return App.style.textField.materialStyleMap(color: color, titleColor: titleColor, disabledColor: disabledColor, textSize: textSize, secondarySize: secondarySize)
    }

    public static var defaultMaterialStyleMap: TextFieldStyleMap {
        return App.style.textField.defaults.materialTextFieldMap
    }

    public static var lightMaterialStyleMap: TextFieldStyleMap {
        return materialStyleMap(color: .textLight)
    }

    public static var darkMaterialStyleMap: TextFieldStyleMap {
        return materialStyleMap(color: .textDark)
    }

    public static func materialStyleMap(contrasting color: UIColor) -> TextFieldStyleMap {
        if color == .primary { return self.materialStyleMap(color: .primaryContrast) }
        if color == .primaryContrast { return self.materialStyleMap(color: .primary) }
        let contrast = color.contrastingColor(fromCandidates: [.textDark, .textLight, .primary, .primaryContrast])
        return self.materialStyleMap(color: contrast)
    }
}
