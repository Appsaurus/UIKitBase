
import UIKitExtensions

open class KeyboardLayoutManager: NSObject{
    
    open var currentKeyboardHeight: CGFloat = 0
    public static let sharedInstance = KeyboardLayoutManager()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func startListening(){
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutManager.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutManager.keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc open func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let kKeyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
            currentKeyboardHeight = (kKeyBoardFrame?.size.height)!
        }
    }
    
    @objc open func keyboardWillHideNotification(_ notification: Notification) {
        currentKeyboardHeight = 0
    }
}


open class KeyboardAwareLayoutConstraint: NSLayoutConstraint, NotificationObserver {
    var storyboardInstantiated: Bool = true
    open var currentKeyboardHeight: CGFloat = 0
    open var constantWhenKeyboardHidden: CGFloat!
    open override var constant: CGFloat{
        didSet{
            //In the cases where constantWhenKeyboardHidden is not set explictly, it is assumed that the regular constant value is desired.
            guard constantWhenKeyboardHidden == nil else { return }
            constantWhenKeyboardHidden = constant
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        didInit()
    }
    
    open func didInit(){
        setupNotificationObserverCallback()
        //constantWhenKeyboardHidden = self.constant
    }
    
    open func notificationsToObserve() -> [Notification.Name] {
        return [UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification]
    }
    open func didObserve(notification: Notification){
        
        switch notification.name{
        case UIResponder.keyboardWillShowNotification:
            let keyboardFrame = self.keyboardFrame(notification)
            let keyboardHeight = keyboardFrame.height
            let deltaHeight = keyboardHeight - currentKeyboardHeight
            keyboardWillShow(keyboardFrame, deltaHeight: deltaHeight, notification: notification)
            currentKeyboardHeight = keyboardHeight
        case UIResponder.keyboardWillHideNotification:
            currentKeyboardHeight = 0.0
            keyboardWillHide(notification)
        default: break
        }
    }
    
    open func keyboardWillHide(_ notification: Notification){
        
    }
    
    open func keyboardWillShow(_ keyboardEndFrame: CGRect, deltaHeight: CGFloat, notification: Notification){
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func animateConstant(_ constant: CGFloat, notification: Notification){
        
        guard let userInfo: [AnyHashable: Any] = notification.userInfo else{
            return
        }
        
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else{
            return
        }
        
        let options = UIView.AnimationOptions(rawValue: curve.uintValue)
        let view = self.firstItem as! UIView
        view.animateConstraintChanges({ [weak self] in
            self?.constant = constant
            }, configuration: AnimationConfiguration(duration: duration.doubleValue, options: options))
    }
    
    open func keyboardFrame(_ notification: Notification, convertFromView: UIView? = nil) -> CGRect{
        guard let userInfo = notification.userInfo else { return CGRect.zero }
        let kKeyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        return kKeyBoardFrame!
//        return UIApplication.mainWindow.convert(kKeyBoardFrame!, to: UIApplication.mainWindow)
//        if let view = convertFromView{
//            return view.convert(kKeyBoardFrame!, from:nil)
//        }
//        else{
//            return kKeyBoardFrame!
//        }
    }
}

open class KeyboardAdjustableLayoutConstraint: KeyboardAwareLayoutConstraint{
    
    @IBInspectable open var constantWhenKeyboardVisible: CGFloat = 0
    
    open class func createConstraint(item view1: AnyObject, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation, toItem view2: AnyObject?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat, keyboardHiddenConstant: CGFloat, keyboardVisibleConstant: CGFloat) -> KeyboardAdjustableLayoutConstraint{
        let constraint = KeyboardAdjustableLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: keyboardHiddenConstant)
        constraint.didInit()
        constraint.constantWhenKeyboardVisible = keyboardVisibleConstant
        constraint.constantWhenKeyboardHidden = keyboardHiddenConstant
        return constraint
    }
    
    open override func keyboardWillHide(_ notification: Notification) {
        animateConstant(constantWhenKeyboardHidden, notification: notification)
    }
    
    open override func keyboardWillShow(_ keyboardEndFrame: CGRect, deltaHeight: CGFloat, notification: Notification) {
        animateConstant(constantWhenKeyboardVisible, notification: notification)
    }
}

open class KeyboardDodgingLayoutConstraint: KeyboardAwareLayoutConstraint {
    
    open var scrollViewToAdjust: UIScrollView?
    open var originalBotomInset: CGFloat?
    
    open class func createConstraint(item view1: AnyObject, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation = .equal, toItem view2: AnyObject?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat = 0.0, keyboardHiddenConstant: CGFloat = 0.0) -> KeyboardDodgingLayoutConstraint{
        let constraint = KeyboardDodgingLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: keyboardHiddenConstant)
        constraint.didInit()
        constraint.constantWhenKeyboardHidden = keyboardHiddenConstant
        if let sv1 = view1 as? UIScrollView{
            constraint.scrollViewToAdjust = sv1
        }
        
        if let sv2 = view2 as? UIScrollView{
            constraint.scrollViewToAdjust = sv2
        }
        constraint.originalBotomInset = constraint.scrollViewToAdjust?.contentInset.bottom
        return constraint
    }
    
    open override func keyboardWillHide(_ notification: Notification) {
        animateConstant(constantWhenKeyboardHidden, notification: notification)
        if let sv = scrollViewToAdjust, let bottom = originalBotomInset{
            sv.contentInset.bottom = bottom
        }
    }
    
    open override func keyboardWillShow(_ keyboardEndFrame: CGRect, deltaHeight: CGFloat, notification: Notification) {
        
        if let firstView = firstItem as? UIView{
            firstView.superview?.setNeedsLayout()
            firstView.superview?.layoutIfNeeded()//Need final frame of view to calculate overlap properly
            let keyboardMinY = UIScreen.screenHeight - keyboardEndFrame.h
            let viewMaxY = firstView.frameInMainWindow.maxY
            let yOverlap: CGFloat = viewMaxY - keyboardMinY
            if yOverlap > 0 {
                let newConstant = constantWhenKeyboardHidden - yOverlap
                
                animateConstant(newConstant, notification: notification)
                if let sv = scrollViewToAdjust, let bottom = originalBotomInset{
                    sv.contentInset.bottom = bottom + yOverlap
                }
            }            
        }
    }
}

open class KeyboardPaddedLayoutConstraint: KeyboardAwareLayoutConstraint{
    
    open override func keyboardWillShow(_ keyboardEndFrame: CGRect, deltaHeight: CGFloat, notification: Notification) {
        if firstItem is UIView{
            let newConstant = constantWhenKeyboardHidden - deltaHeight
            animateConstant(newConstant, notification: notification)
        }
    }
}

open class KeyboardAdjustingScrollViewConstraint: KeyboardAwareLayoutConstraint{
    open override func keyboardWillShow(_ keyboardEndFrame: CGRect, deltaHeight: CGFloat, notification: Notification) {
        
    }
    
    open override func keyboardWillHide(_ notification: Notification) {
        
    }
}
