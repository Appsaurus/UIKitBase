//
//  BaseButton.swift
//  Pods
//
//  Created by Brian Strobach on 7/21/17.
//
//

import UIKit
import DinoDNA
import UIKitTheme
import UIFontIcons
import UIKitExtensions

//MARK: Image heights are porportionate to button's frame, normalized between 0.0 and 1.0
public enum ButtonLayoutType{
    case centerTitleUnderImage(padding: CGFloat)
    case imageLeftTitleCenter
    case imageLeftTitleStackedRight(padding: CGFloat)
    case imageRightTitleCenter
    case imageRightTitleStackedLeft(padding: CGFloat)
    case imageAndTitleCentered(padding: CGFloat)
    case titleCentered
    case imageCentered
}

public enum ButtonImageLayoutType{
    case square
    case stretchWidth
}


public func ==(lhs: ButtonState, rhs: String) -> Bool{
    return lhs.rawValue == rhs
}

public func ==(lhs: String, rhs: ButtonState) -> Bool{
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

public typealias ButtonImageUrlMap = [ButtonState : String]
public typealias ButtonImageMap = [ButtonState : UIImage]
public typealias ButtonAttributedTitleMap = [ButtonState : NSAttributedString]
public typealias ButtonTitleMap = [ButtonState : String]
public typealias ButtonStyleMap = [ButtonState : ButtonStyle]
public typealias ButtonTapActionMap = [ButtonState : VoidClosure]
public typealias ButtonIconMap<FontIcon: FontIconEnum> = [ButtonState: FontIcon]



open class ButtonLayout{
    public var layoutType: ButtonLayoutType
    public var imageLayoutType: ButtonImageLayoutType
    public var marginInsets: UIEdgeInsets
    public var imageInsets: UIEdgeInsets = .zero
    
    public init(layoutType: ButtonLayoutType = .imageLeftTitleCenter, imageLayoutType: ButtonImageLayoutType = .square, marginInsets: UIEdgeInsets? = nil, imageInsets: UIEdgeInsets? = nil) {
        self.layoutType = layoutType
        self.imageInsets =? imageInsets
        self.imageLayoutType = imageLayoutType
        guard let marginInsets = marginInsets else {
            switch layoutType{
            case .titleCentered:
                self.marginInsets = .zero
            default:
                self.marginInsets = UIEdgeInsets(horizontalPadding: 10.0, verticalPadding: 5.0)
            }
            return
        }
        self.marginInsets = marginInsets
    }
}

public enum ButtonDisableBehavior{
    case dropAlpha(to: CGFloat)
    //    case desaturate
}

public enum ButtonActivityBehavior{
    case removeTitle
    case showIndicator(style: UIActivityIndicatorView.Style, at: ActivityIndicatorPosition)
}


extension BaseButton: TextStyleable{
    public func apply(textStyle: TextStyle){
        titleLabel.apply(textStyle: textStyle)
    }
}

open class BaseButton: BaseView, ButtonStyleable{
    
    open var onTap: VoidClosure?
    open var adjustsFrameToFitContent: Bool = false
    open var tapRecognizer: UITapGestureRecognizer?
    open var contentLayoutView: UIView = UIView()
    open var titleLabel: UILabel = UILabel()
    open var imageView: BaseImageView = BaseImageView()
    open var tintsImagesToMatchTextColor: Bool = false{
        didSet{
            imageView.tintsImages = tintsImagesToMatchTextColor
        }
    }
    
    open lazy var buttonLayout: ButtonLayout = ButtonLayout()
    open var activityBehaviors: [ButtonActivityBehavior] = [.removeTitle, .showIndicator(style: .white, at: .center)]
    open var disabledBehaviors: [ButtonDisableBehavior] = [.dropAlpha(to: 0.5)]
    open var buttonTapActionMap: ButtonTapActionMap = [:]
    open var attributedTitleMap: ButtonAttributedTitleMap = [:]{
        didSet{
            applyCurrentStateConfiguration()
        }
    }
    open var titleMap: ButtonTitleMap = [:]{
        didSet{
            applyCurrentStateConfiguration()
        }
    }
    open var styleMap: ButtonStyleMap = [:]{
        didSet{
            applyCurrentStateConfiguration()
        }
    }
    
    open var imageMap: ButtonImageMap = [:]{
        didSet{
            applyCurrentStateConfiguration()
        }
    }
    
    open var imageUrlMap: ButtonImageUrlMap = [:]{
        didSet{
            applyCurrentStateConfiguration()
        }
    }
    
    open var state: ButtonState = .normal{
        didSet{
            if oldValue != state{
                previousState = oldValue
                stateDidChange()
            }
        }
    }
    
    open var previousState: ButtonState?
    
    open func stateDidChange(){
        applyCurrentStateConfiguration()
        additionalStateChangeActions()
    }
    open func additionalStateChangeActions(){
        
        if state == .disabled{
            applyDisabledStateBehaviors()
        }
        else if previousState == .disabled{
            removeDisabledStateBehaviors()
        }
        if state == .activity{
            applyActivityStateBehaviors()
        }
        else if previousState == .activity{
            removeActivityStateBehaviors()
        }
        
    }
    
    
    //MARK: Initialization
    public convenience init(frame: CGRect = .zero,
                            titles: ButtonTitleMap? = nil,
                            attributedTitles: ButtonAttributedTitleMap? = nil,
                            imageMap: ButtonImageMap? = nil,
                            imageUrlMap: ButtonImageUrlMap? = nil,
                            styleMap: ButtonStyleMap? = nil,
                            buttonLayout: ButtonLayout = ButtonLayout(),
                            onTap: VoidClosure? = nil){
        self.init(callDidInit: false)
        self.titleMap =? titles
        self.attributedTitleMap =? attributedTitles
        self.imageMap =? imageMap
        self.imageUrlMap =? imageUrlMap
        self.styleMap =? styleMap
        self.buttonLayout = buttonLayout
        self.onTap =? onTap
        didInitProgramatically()
    }
    
    public convenience init<T: FontIconEnum>(frame: CGRect = .zero, icon: T, style: ButtonStyle? = nil, buttonLayout: ButtonLayout? = nil, onTap: VoidClosure? = nil){
        self.init(callDidInit: false)
        let font = icon.getFont(style?.textStyle.font.pointSize ?? fontSize)
        if style?.textStyle.font.fontName != icon.fontName{
            style?.textStyle.font = font
        }
        
        styleMap[.any] = style ?? ButtonStyle(textStyle: TextStyle(color: .primaryContrast, font: font), viewStyle: ViewStyle())
        titleMap[.any] = icon.rawValue
        self.buttonLayout =? buttonLayout
        self.onTap =? onTap
        didInitProgramatically()
    }
    
    public convenience init(frame: CGRect = .zero, style: ButtonStyle, buttonLayout: ButtonLayout? = nil, onTap: VoidClosure? = nil){
        self.init(callDidInit: false)
        styleMap[.any] = style
        self.buttonLayout =? buttonLayout
        self.onTap =? onTap
        didInitProgramatically()
    }
    
    
    public override init(callDidInit: Bool = true){
        super.init(callDidInit: callDidInit)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        imageView.tintsImages = tintsImagesToMatchTextColor
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.lineBreakMode = .byTruncatingTail
        applyCurrentStateConfiguration()
        
        addTap { [weak self] (view) in
            guard let `self` = self else { return }
            self.buttonWasTapped(view: view)
        }
    }
    
    open func buttonWasTapped<V: UIView>(view: V){
        let action = buttonTapActionMap.firstValue(for: .overrideAll, state, .any) ?? onTap
        action?()
    }
    
    open override func createSubviews() {
        super.createSubviews()
        addSubview(contentLayoutView)
        contentLayoutView.addSubviews([titleLabel, imageView])
    }
    
    
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        apply(buttonLayout: self.buttonLayout)
    }
    
    //MARK: Touch handling, passing along touches when disabled
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if state == .disabled && buttonTapActionMap[.disabled] == nil{
            return false
        }
        if state == .activity && buttonTapActionMap[.activity] == nil{
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    open func apply(buttonLayout: ButtonLayout){
        contentLayoutView.autoForceSuperviewToMatchContentSize(insetBy: buttonLayout.marginInsets)
        switch buttonLayout.layoutType {
        case .centerTitleUnderImage(let padding):
            imageView.autoPinToSuperview(edge: .top, withOffset: buttonLayout.imageInsets.top)
            imageView.autoPinToSuperview(edges: .leftAndRight, withInsets: buttonLayout.imageInsets, relatedBy: .greaterThanOrEqual)
            imageView.autoCenterHorizontallyInSuperview()
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType)
            
            titleLabel.autoEnforceContentSize()
            titleLabel.autoPinToSuperview(excludingEdges: [.top])
            titleLabel.autoSizeHeight(to: 0.0, relatedBy: .greaterThanOrEqual)
            titleLabel.autoPin(edge: .top, toEdge: .bottom, of: imageView, withOffset: padding)
            titleLabel.textAlignment = .center
            
        case .imageLeftTitleStackedRight(let padding):
            imageView.autoPinToSuperview(excludingEdges: [.right], withInsets: buttonLayout.imageInsets)
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType)
            titleLabel.autoPinToSuperview(excludingEdges: [.left])
            titleLabel.autoPin(edge: .left, toEdge: .right, of: imageView, withOffset: padding)
            titleLabel.textAlignment = .left
        case .imageRightTitleStackedLeft(let padding):
            imageView.autoPinToSuperview(excludingEdges: [.left], withInsets: buttonLayout.imageInsets)
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType)
            titleLabel.autoPinToSuperview(excludingEdges: [.right])
            titleLabel.autoPin(edge: .right, toEdge: .left, of: imageView, withOffset: padding)
            titleLabel.textAlignment = .right
            
        case .imageLeftTitleCenter:
            imageView.autoPinToSuperview(excludingEdges: [.right], withInsets: buttonLayout.imageInsets)
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)
            titleLabel.autoPinToSuperview()
            titleLabel.textAlignment = .center
        case .imageRightTitleCenter:
            imageView.autoPinToSuperview(excludingEdges: [.left])
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)
            titleLabel.autoPinToSuperview()
            titleLabel.textAlignment = .center
        case .titleCentered:
            titleLabel.autoForceSuperviewToMatchContentSize()
            titleLabel.textAlignment = .center
        case .imageCentered:
            imageView.autoForceSuperviewToMatchContentSize(insetBy: buttonLayout.imageInsets)
            imageView.autoSizeWidth(to: 0.0, relatedBy: .greaterThanOrEqual)
            imageView.autoSizeHeight(to: 0.0, relatedBy: .greaterThanOrEqual)
        case .imageAndTitleCentered(let padding):
            
            imageView.autoEnforceContentSize()
            imageView.autoPinToSuperview(excludingEdges: [.right], withInsets: buttonLayout.imageInsets)
            imageView.autoPin(edge: .right, toEdge: .left, of: titleLabel, withOffset: padding + buttonLayout.imageInsets.right)
            createImageLayoutConstraints(for: imageView, ofType: buttonLayout.imageLayoutType, masterAttribute: .height)
            
            titleLabel.anchorTopAndBottomToSuperview()
            titleLabel.autoPinToSuperview(edge: .right, relatedBy: .greaterThanOrEqual)
            //            titleLabel.autoCenterHorizontallyInSuperview(relatedBy: .greaterThanOrEqual)
            //            titleLabel.anchorLeading(equalTo: imageView.trailingAnchor)
            titleLabel.autoSizeWidth(to: 0.0, relatedBy: .greaterThanOrEqual)
            
            titleLabel.autoEnforceContentSize()
            titleLabel.textAlignment = .center
        }
        
        
    }
    
    open func createImageLayoutConstraints(for imageView: UIImageView, ofType type: ButtonImageLayoutType, masterAttribute: NSLayoutConstraint.Attribute = .width){
        switch type{
        case .square:
            imageView.autoSizeAspectRatio(to: .square, masterAttribute: masterAttribute)
        case .stretchWidth:
            imageView.autoConstrain(attribute: .width, toAttribute: .height, ofItem: imageView, relatedBy: .greaterThanOrEqual, priority: .required)
        }
    }
    
    open func applyCurrentStateConfiguration(){
        applyCurrentButtonStyle()
        applyCurrentImage()
        applyCurrentTitle()
    }
    
    
    open func applyCurrentTitle(){
        guard attributedTitleMap[.overrideAll] == nil else {
            titleLabel.attributedText = attributedTitleMap[.overrideAll]
            return
        }
        
        guard titleMap[.overrideAll] == nil else {
            titleLabel.text = titleMap[.overrideAll]
            return
        }
        
        if let attributedTitle = attributedTitleMap.firstValue(for: state, .any){
            titleLabel.attributedText = attributedTitle
        }
        else if let title = titleMap.firstValue(for: state, .any){
            titleLabel.text = title
        }
    }
    
    open func applyCurrentImage(){
        if tintsImagesToMatchTextColor{
            imageView.tintColor = titleLabel.textColor
        }
        guard imageUrlMap[.overrideAll] == nil else {
            imageView.displayImage(withUrlString: imageUrlMap[.overrideAll]!)
            return
        }
        
        guard imageMap[.overrideAll] == nil else {
            imageView.image = imageMap[.overrideAll]!
            return
        }
        
        if let imageUrl = imageUrlMap.firstValue(for: state, .any){
            imageView.displayImage(withUrlString: imageUrl)
        }
        else if let image = imageMap.firstValue(for: state, .any){
            imageView.image = image
        }
    }
    
    
    public func setTitle(_ title: String?, for state: ButtonState = .any){
        titleMap[state] = title
    }
    
    open override func style() {
        super.style()
        applyCurrentButtonStyle()
    }
    
    
    open func applyCurrentButtonStyle(){
        if let buttonStyle = styleMap.firstValue(for: .overrideAll, state, .any){
            apply(buttonStyle: buttonStyle)
        }
        
    }
    
    internal var cachedAlpha: CGFloat?
    open func applyDisabledStateBehaviors(){
        for behavior in disabledBehaviors{
            switch behavior{
            case .dropAlpha(let value):
                cachedAlpha ??= alpha
                alpha = value
            }
        }
    }
    
    open func removeDisabledStateBehaviors(){
        for behavior in disabledBehaviors{
            switch behavior{
            case .dropAlpha:
                alpha =? cachedAlpha
                cachedAlpha = nil
            }
        }
    }
    
    internal var cachedTitleAlpha: CGFloat?
    open func applyActivityStateBehaviors(){
        for behavior in activityBehaviors{
            switch behavior{
            case .removeTitle:
                cachedTitleAlpha ??= titleLabel.alpha
                titleLabel.alpha = 0.0
            case .showIndicator(let style, let position):
                showActivityIndicator(style: style, useAutoLayout: false, position: position)
            }
        }
    }
    
    open func removeActivityStateBehaviors(){
        for behavior in activityBehaviors{
            switch behavior{
            case .removeTitle:
                titleLabel.alpha =? cachedTitleAlpha
                cachedTitleAlpha = nil
            case .showIndicator:
                hideActivityIndicator()
            }
        }
    }
}

extension BaseButton{
    public var fontSize: CGFloat{
        set{
            if let font = self.titleLabel.font{
                self.titleLabel.font = font.withSize(newValue)
            }
            else{
                self.titleLabel.font = UIFont.systemFont(ofSize: newValue)
            }
        }
        get{
            return self.titleLabel.font.pointSize
        }
    }
    
    public var fontName: String{
        set{
            self.titleLabel.font = UIFont(name: newValue, size: fontSize)
        }
        get{
            return self.titleLabel.font?.familyName ?? UIFont.systemFont(ofSize: fontSize).familyName
        }
    }
    
    //TODO: Improve this, rough calculation for usage in UIBarButtonItems
    public func calculateMaxButtonSize() -> CGSize{
        let titleSize = titleMap.values.max()?.size(OfFont: titleLabel.font) ?? CGSize.zero
        let imageSize = imageMap.values.max(by: { (image1, image2) -> Bool in
            return image1.size.width > image2.size.width
        })?.size ?? .zero
        var size = titleSize + imageSize
        size.height += (buttonLayout.marginInsets.top + buttonLayout.marginInsets.bottom + buttonLayout.imageInsets.top + buttonLayout.imageInsets.bottom)
        size.width += (buttonLayout.marginInsets.left + buttonLayout.marginInsets.right + buttonLayout.imageInsets.left + buttonLayout.imageInsets.right)
        return size
    }
}
