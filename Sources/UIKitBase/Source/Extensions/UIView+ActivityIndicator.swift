//
//  UIView+ActivityIndicator.swift
//  UIKitBase
//
//  Created by Brian Strobach on 8/4/17.
//
//

import Foundation
import Layman
import UIKit
public enum ActivityIndicatorPosition {
    case center, leading, trailing
}

public extension UIBarButtonItem {
    func showActivityIndicator(style: UIActivityIndicatorView.Style = .medium, position: ActivityIndicatorPosition = .center) {
        guard let customView = self.customView else {
            assertionFailure("You can only show activity indicator on a UIBarButtonItem with a customView.")
            return
        }
        customView.showActivityIndicator(style: style, useAutoLayout: false, position: position)
    }

    func hideActivityIndicator() {
        guard let customView = self.customView else {
            assertionFailure("You can only show activity indicator on a UIBarButtonItem with a customView.")
            return
        }
        customView.hideActivityIndicator()
    }
}

public extension UIView {
    /**
     Creates and starts animating a UIActivityIndicator in any UIView
     Parameter style: `UIActivityIndicatorViewStyle` default is .gray
     */

    func showActivityIndicator(style: UIActivityIndicatorView.Style = .medium,
                               color: UIColor? = nil,
                               useAutoLayout: Bool = true,
                               position: ActivityIndicatorPosition = .center,
                               disablingUserInteraction: Bool = true,
                               disablingGlobalUserInteraction: Bool = false)
    {
        // Indicator already exists, make sure it is visible but do not create another
        if let indicator: UIActivityIndicatorView = subview(withTag: UIViewExtensionTag.activityIndicator) as? UIActivityIndicatorView {
            bringSubviewToFront(indicator)
            indicator.startAnimating()
            return
        }
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        indicator.apply(viewStyle: viewStyle())
        indicator.cornerRadius = cornerRadius
        var backgroundView: UIView? = self
        while backgroundView != nil, indicator.backgroundColor == .clear {
            indicator.backgroundColor = backgroundView?.backgroundColor
            if let parent = backgroundView?.superview {
                backgroundView = parent
            } else {
                break
            }
        }

        indicator.tag = UIViewExtensionTag.activityIndicator.rawValue
        addSubview(indicator)

        if useAutoLayout {
            switch position {
            case .center:
                indicator.equal(to: edges)
            case .trailing:
                indicator.equal(to: edges.excluding(.leading))
            case .leading:
                indicator.equal(to: edges.excluding(.trailing))
            }
        } else {
            switch position {
            case .center:
                indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                indicator.center = center
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
        if disablingUserInteraction {
            isUserInteractionEnabled = false
        }
        if disablingGlobalUserInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }

    /**
     Stops and removes an UIActivityIndicator in any UIView
     */
    func hideActivityIndicator(enablingUserInteraction: Bool = true, enablingGlobbalUserInteraction: Bool = true) {
        guard let indicator: UIActivityIndicatorView = subview(withTag: UIViewExtensionTag.activityIndicator) as? UIActivityIndicatorView else {
            return
        }
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        if enablingUserInteraction {
            isUserInteractionEnabled = true
        }
        if enablingGlobbalUserInteraction {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

public protocol UIViewTag: RawRepresentable {
    var rawValue: Int { get }
}

/// Tags for any views that are created by an extension method and need to be accessed at later time.
/// Used as an alternative to storing references in associated objects via obj-c runtime.
///
/// - activityIndicator: 1001
public enum UIViewExtensionTag: Int, UIViewTag {
    case activityIndicator = 1001
}

public extension UIView {
    func subview<VT: UIViewTag>(withTag tag: VT) -> UIView? {
        return viewWithTag(tag.rawValue)
    }
}
