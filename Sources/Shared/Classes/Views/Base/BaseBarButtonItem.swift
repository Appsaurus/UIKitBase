//
//  BaseBarButtonItem.swift
//  Pods
//
//  Created by Brian Strobach on 4/19/17.
//
//

import UIKitMixinable
import Swiftest
import UIFontIcons
public protocol BaseBarButtonItemProtocol:
    BaseNSObjectProtocol
{}

extension BaseBarButtonItemProtocol where Self: UIBarButtonItem{
    public var baseBarButtonItemProtocolMixins: [LifeCycle]{
        return baseNSObjectProtocolMixins
    }
}

open class BaseBarButtonItem: MixinableBarButtonItem, BaseBarButtonItemProtocol{
    
    override open func createMixins() -> [LifeCycle] {
        return super.createMixins() + baseBarButtonItemProtocolMixins
    }
    
    //MARK: Convenience Initializers
    public convenience init<T: FontIconEnum>(icon: T,
                                                     fontSize: CGFloat = .barButtonFontIconSize,
                                                     onTouchUpInside: VoidClosure? = nil){
        let button = UIButton()
        button.setFontIconTitle(icon, fontSize: fontSize)
        self.init(customButton: button, onTouchUpInside: onTouchUpInside)
    }
    
    public convenience init(customButton: UIButton, onTouchUpInside: VoidClosure? = nil){
        //TODO: Change to 66 x 66 for Plus sized iPhones
        customButton.frame = CGRect(x: 0, y: 0, width: 44.0 , height: 44.0)
        if let onTouchUpInside = onTouchUpInside{
            customButton.addAction(forControlEvents: .touchUpInside) {
                onTouchUpInside()
            }
        }
        self.init(customView: customButton)
    }
    
    //MARK: NotificationObserver
    open func notificationsToObserve() -> [Notification.Name]{
        return []
    }
    open func notificationClosureMap() -> NotificationClosureMap{
        return [:]
    }
    
    open func didObserve(notification: Notification){}
    
    //MARK: Styleable
    open func style() {}
    

}
