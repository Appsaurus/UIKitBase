//
//  UIView+ActivityIndicator.swift
//  UIKitBase
//
//  Created by Brian Strobach on 8/4/17.
//
//

import Foundation
import UIKit
import Layman
public enum ActivityIndicatorPosition{
    case center, leading, trailing
}

extension UIBarButtonItem{
    public func showActivityIndicator(style: UIActivityIndicatorView.Style = .gray, position: ActivityIndicatorPosition = .center){
        guard let customView = self.customView else {
            assertionFailure("You can only show activity indicator on a UIBarButtonItem with a customView.")
            return
        }
        customView.showActivityIndicator(style: style, useAutoLayout: false, position: position)
    }
    public func hideActivityIndicator(){
        guard let customView = self.customView else {
            assertionFailure("You can only show activity indicator on a UIBarButtonItem with a customView.")
            return
        }
        customView.hideActivityIndicator()
    }
}

extension UIView{
    
    
    /**
     Creates and starts animating a UIActivityIndicator in any UIView
     Parameter style: `UIActivityIndicatorViewStyle` default is .gray
     */
    
    public func showActivityIndicator(style: UIActivityIndicatorView.Style = .gray, useAutoLayout: Bool = true, position: ActivityIndicatorPosition = .center){
        if let indicator: UIActivityIndicatorView = self.subview(withTag: UIViewExtensionTag.activityIndicator) as? UIActivityIndicatorView { //Indicator already exists, make sure it is visible but do not create another
            bringSubviewToFront(indicator)
            indicator.startAnimating()
            return
        }
        let indicator = UIActivityIndicatorView(style: style)
        indicator.apply(viewStyle: self.viewStyle())
        while let superview = superview, indicator.backgroundColor == .clear{
            indicator.backgroundColor = superview.backgroundColor
            indicator.cornerRadius = superview.cornerRadius
        }
        indicator.tag = UIViewExtensionTag.activityIndicator.rawValue
        addSubview(indicator)
        
        if useAutoLayout{
            switch position{
            case .center:
                indicator.equal(to: edges)
            case .trailing:
                indicator.equal(to: edges.excluding(.leading))
            case .leading:
                indicator.equal(to: edges.excluding(.trailing))
            }
        }
        else{
            switch position{
            case .center:
                indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                indicator.center = self.center
                indicator.frame = bounds
            case .trailing:
                indicator.frame.size = CGSize(side: frame.h)
                indicator.autoresizingMask = [.flexibleHeight]
                indicator.center = CGPoint(x: frame.w - (indicator.frame.w / 2.0), y: frame.h / 2.0)
            case .leading:
                indicator.frame.size = CGSize(side: frame.h)
                indicator.autoresizingMask = [.flexibleHeight]
                indicator.center = CGPoint(x: indicator.frame.w, y: frame.h / 2.0)
            }
            
        }
        bringSubviewToFront(indicator)
        indicator.startAnimating()
    }
    
    /**
     Stops and removes an UIActivityIndicator in any UIView
     */
    public func hideActivityIndicator(){
        guard let indicator: UIActivityIndicatorView = self.subview(withTag: UIViewExtensionTag.activityIndicator) as? UIActivityIndicatorView else{
            return
        }
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
}

public protocol UIViewTag: RawRepresentable {
    var rawValue: Int { get }
}


/// Tags for any views that are created by an extension method and need to be accessed at later time.
/// Used as an alternative to storing references in associated objects via obj-c runtime.
///
/// - activityIndicator: 1001
public enum UIViewExtensionTag: Int, UIViewTag{
    case activityIndicator = 1001
}

extension UIView{
    public func subview<VT: UIViewTag>(withTag tag: VT) -> UIView?{
        return viewWithTag(tag.rawValue)
    }
}