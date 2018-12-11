////
////  BaseTextField.swift
////  Pods
////
////  Created by Brian Strobach on 8/8/17.
////
////
//
//import UIKitMixinable
//import UIKitTheme
//
//public protocol BaseTextFieldProtocol:
//    BaseViewProtocol
//{}
//
//extension BaseTextFieldProtocol where Self: UITextField{
//    public var baseTextFieldProtocolMixins: [LifeCycle]{
//        return [] + baseViewProtocolMixins
//    }
//}
//
//open class BaseTextField: MixinableTextField, BaseTextFieldProtocol{
//    
//    override open func createMixins() -> [LifeCycle] {
//        return super.createMixins() + baseTextFieldProtocolMixins
//    }
//    
//    //MARK: NotificationObserver
//    open func notificationsToObserve() -> [Notification.Name]{
//        return []
//    }
//    open func notificationClosureMap() -> NotificationClosureMap{
//        return [:]
//    }
//    
//    open func didObserve(notification: Notification){}
//    
//    //MARK: Styleable
//    open func style() {}
//    
//
//}
//
//
//public typealias TextFieldStyleMap = [TextFieldState : TextFieldStyle]
//
//public enum TextFieldState: State{
//    case none
//    case inactive
//    case active
//    case disabled
//    case readOnly
//    case processing    
//}
//
//open class StatefulTextField: BaseTextField{
//
//    open var adjustsFontSizeToFitHeight: Bool = false
//    
//    //MARK: State
//    open var currentState: TextFieldState{
//        if isReadOnly { return .readOnly }
//        if !isEnabled { return .disabled }
//        if isFirstResponder { return .active}
//        return .inactive
//    }
//    open var previousState: TextFieldState = .none
//    
//    open var styleMap: TextFieldStyleMap = [:]{
//        didSet{
//            applyCurrentStateConfiguration()
//        }
//    }
//    
//    open override var isSelected: Bool{
//        didSet{
//            applyCurrentStateConfiguration()
//        }
//    }
//    
//    open override var isEnabled: Bool{
//        didSet{
//            applyCurrentStateConfiguration()
//        }
//    }
//
//    open var isReadOnly: Bool = false{
//        didSet{
//            if isEnabled{
//                isEnabled = false //Will trigger state update
//                return
//            }
//            applyCurrentStateConfiguration()
//        }
//    }
//    
//    open var hidesCaret: Bool = false
//    open var matchesCaretToTextColor: Bool = true
//    open var defaultStyleAdjustsToBackgroundColor: Bool = true
//    
//    open var labelAnimationConfiguration: AnimationConfiguration{
//        return  AnimationConfiguration(duration: 0.3, options: [.curveEaseInOut, .allowAnimatedContent])
//    }
//    
//    open func applyCurrentStateConfiguration(animated: Bool = false){
//        if previousState != currentState{
//            previousState = currentState
//        }
//        
//        if currentState == .inactive && text.hasNonEmptyValue{
//            //Fixes UIKit bug where text input jumps vertically on first resignation.
//            //Shitty and may have unforeseen side effects. Find better fix or consider living with UITextField bug.
//            forceAutolayoutPass()
//        }
//        
//        guard animated else {
//            self.applyCurrentTextFieldStyle()
//            self.layoutSubviews(for: self.currentState)
//            return
//        }
//        
//        animate(configuration: labelAnimationConfiguration, animations: { [weak self] in
//            guard let `self` = self else { return }
//            self.applyCurrentTextFieldStyle()
//            self.layoutSubviews(for: self.currentState)
//            
//        })
//    }
//    
//    
//    
//    //MARK: Layout
//    open func layoutSubviews(for state: TextFieldState){
//        
//    }
//    
//    //MARK: Style
//    open func applyCurrentTextFieldStyle(){
//        if let textFieldStyle = styleMap[currentState]{
//            apply(textFieldStyle: textFieldStyle)
//        }
//        if matchesCaretToTextColor, let color = textColor{
//            setCaret(color: color)
//        }
//    }
//    
//    open func apply(textFieldStyle: TextFieldStyle){
//        apply(textStyle: textFieldStyle.textStyle)
//        apply(viewStyle: textFieldStyle.viewStyle, optimizeRendering: false)
//    }
//    
//
//    
//    open override func setupControlActions() {
//        addTarget(self, action: #selector(StatefulTextField.controlEventFired), for: UIControl.Event.allEvents)
//    }
//
//    
//    @objc open func controlEventFired() {
//        applyCurrentStateConfiguration(animated: true)
//    }
//    
//    
//    open override func caretRect(for position: UITextPosition) -> CGRect {
//        guard hidesCaret else { return super.caretRect(for: position)}
//        return .zero
//    }
//    
//    open override func style() {
//        applyCurrentTextFieldStyle()
//    }
//    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        if adjustsFontSizeToFitHeight{
//            adjustsFontSizeToFitWidth = false
//            adjustFontSizeToFitHeight()
//        }
//        
//        layoutSubviews(for: self.currentState)
//    }
//
//}
