//
//  GradientView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 5/25/17.
//
//

import UIKitTheme
/// Simple view for drawing gradients and borders.
@IBDesignable open class GradientView: BaseView {
    // MARK: - Types

    /// The mode of the gradient.
    @objc public enum Mode: Int {
        /// A linear gradient.
        case linear

        /// A radial gradient.
        case radial
    }

    /// The direction of the gradient.
    @objc public enum Direction: Int {
        /// The gradient is vertical.
        case vertical

        /// The gradient is horizontal
        case horizontal
    }

    // MARK: - Properties

    /// An optional array of `UIColor` objects used to draw the gradient. If the value is `nil`, the `backgroundColor`
    /// will be drawn instead of a gradient. The default is `nil`.
    open var colors: [UIColor]? {
        didSet {
            updateGradient()
        }
    }

    /// An array of `UIColor` objects used to draw the dimmed gradient. If the value is `nil`, `colors` will be
    /// converted to grayscale. This will use the same `locations` as `colors`. If length of arrays don't match, bad
    /// things will happen. You must make sure the number of dimmed colors equals the number of regular colors.
    ///
    /// The default is `nil`.
    open var dimmedColors: [UIColor]? {
        didSet {
            updateGradient()
        }
    }

    /// Automatically dim gradient colors when prompted by the system (i.e. when an alert is shown).
    ///
    /// The default is `true`.
    open var automaticallyDims: Bool = true

    /// An optional array of `CGFloat`s defining the location of each gradient stop.
    ///
    /// The gradient stops are specified as values between `0` and `1`. The values must be monotonically increasing. If
    /// `nil`, the stops are spread uniformly across the range.
    ///
    /// Defaults to `nil`.
    open var locations: [CGFloat]? {
        didSet {
            updateGradient()
        }
    }

    /// The mode of the gradient. The default is `.Linear`.
    open var mode: Mode = .linear {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The direction of the gradient. Only valid for the `Mode.Linear` mode. The default is `.Vertical`.
    open var direction: Direction = .vertical {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 1px borders will be drawn instead of 1pt borders. The default is `true`.
    @IBInspectable open var drawsThinBorders: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The top border color. The default is `nil`.
    @IBInspectable open var topBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The right border color. The default is `nil`.
    @IBInspectable open var rightBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    ///  The bottom border color. The default is `nil`.
    @IBInspectable open var bottomBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The left border color. The default is `nil`.
    @IBInspectable open var leftBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - UIView

    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let size = bounds.size

        // Gradient
        if let gradient = gradient {
            let options: CGGradientDrawingOptions = [.drawsAfterEndLocation]

            if self.mode == .linear {
                let startPoint = CGPoint.zero
                let endPoint = self.direction == .vertical ? CGPoint(x: 0, y: size.height) : CGPoint(x: size.width, y: 0)
                context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: options)
            } else {
                let center = CGPoint(x: bounds.midX, y: bounds.midY)
                context?.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: min(size.width, size.height) / 2, options: options)
            }
        }

        let screen: UIScreen = window?.screen ?? UIScreen.main
        let borderWidth: CGFloat = self.drawsThinBorders ? 1.0 / screen.scale : 1.0

        // Top border
        if let color = topBorderColor {
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: size.width, height: borderWidth))
        }

        let sideY: CGFloat = self.topBorderColor != nil ? borderWidth : 0
        let sideHeight: CGFloat = size.height - sideY - (self.bottomBorderColor != nil ? borderWidth : 0)

        // Right border
        if let color = rightBorderColor {
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(x: size.width - borderWidth, y: sideY, width: borderWidth, height: sideHeight))
        }

        // Bottom border
        if let color = bottomBorderColor {
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(x: 0, y: size.height - borderWidth, width: size.width, height: borderWidth))
        }

        // Left border
        if let color = leftBorderColor {
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(x: 0, y: sideY, width: borderWidth, height: sideHeight))
        }
    }

    override open func tintColorDidChange() {
        super.tintColorDidChange()

        if self.automaticallyDims {
            self.updateGradient()
        }
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        contentMode = .redraw
    }

    // MARK: - Private

    fileprivate var gradient: CGGradient?

    fileprivate func updateGradient() {
        self.gradient = nil
        setNeedsDisplay()

        let colors = self.gradientColors()
        if let colors = colors {
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorSpaceModel = colorSpace.model

            let gradientColors = colors.map { (color: UIColor) -> AnyObject? in
                let cgColor = color.cgColor
                let cgColorSpace = cgColor.colorSpace ?? colorSpace

                // The color's color space is RGB, simply add it.
                if cgColorSpace.model == colorSpaceModel {
                    return cgColor as AnyObject
                }

                // Convert to RGB. There may be a more efficient way to do this.
                var red: CGFloat = 0
                var blue: CGFloat = 0
                var green: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor as AnyObject
            } as NSArray

            self.gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: self.locations)
        }
    }

    fileprivate func gradientColors() -> [UIColor]? {
        if tintAdjustmentMode == .dimmed {
            if let dimmedColors = dimmedColors {
                return dimmedColors
            }

            if self.automaticallyDims {
                if let colors = colors {
                    return colors.map {
                        var hue: CGFloat = 0
                        var brightness: CGFloat = 0
                        var alpha: CGFloat = 0

                        $0.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)

                        return UIColor(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
                    }
                }
            }
        }

        return self.colors
    }
}

public extension GradientView {
    class func insertGradientBackgroundView(_ superView: UIView, pinnedToView sourceView: UIView,
                                            colors: [UIColor],
                                            size: CGSize,
                                            gradientMode: Mode = .linear,
                                            alpha: CGFloat = 1.0) -> GradientView
    {
        let gradient = GradientView()
        gradient.clipsToBounds = false
        gradient.mode = gradientMode
        gradient.colors = colors
        gradient.alpha = alpha
        superView.insertSubview(gradient, at: 0)
        gradient.centerInSuperview()
        gradient.sizeAnchors.equal(to: superView.sizeAnchors)
        gradient.automaticallyDims = true
        return gradient
    }

    @discardableResult
    class func insertGradientBackgroundView(in view: UIView,
                                            colors: [UIColor] = [.primary,
                                                                 .secondary],
                                            gradientMode: Mode = .linear,
                                            gradientDirection: Direction = .horizontal,
                                            alpha: CGFloat = 1.0) -> GradientView
    {
        let gradientView = self.gradient(ofSize: view.frame.size, colors: colors, gradientMode: gradientMode, gradientDirection: gradientDirection, alpha: alpha)
        view.insertSubview(gradientView, at: 0)
        gradientView.clipsToBounds = true
        gradientView.cornerRadius = view.cornerRadius
        gradientView.pinToSuperview()
        return gradientView
    }

    class func gradient(ofSize size: CGSize,
                        colors: [UIColor] = [.primary,
                                             .secondary],
                        gradientMode: Mode = .linear,
                        gradientDirection: Direction = .horizontal,
                        alpha: CGFloat = 1.0) -> GradientView
    {
        let gradient = GradientView()
        gradient.clipsToBounds = false
        gradient.mode = gradientMode
        gradient.direction = gradientDirection
        gradient.colors = colors
        gradient.alpha = alpha
        gradient.automaticallyDims = true
        return gradient
    }
}

public extension GradientConfiguration {
    func toView(frame: CGRect) -> GradientView {
        let gv = GradientView()
        gv.locations = locations.map { $0.doubleValue.cgFloat }
        gv.colors = colors
        return gv
    }
}
