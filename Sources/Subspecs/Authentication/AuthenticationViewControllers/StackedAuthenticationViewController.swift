//
//  AuthenticationViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 8/1/16.
//  Copyright © 2016 Appsaurus LLC. All rights reserved.
//

import Swiftest
import Layman

open class StackedAuthenticationViewController<ACM: BaseAuthControllerManager>: AuthenticationViewController<ACM> {
    
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    
    open var mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 20.0
        sv.alignment = .center
        sv.distribution = UIStackView.Distribution.equalSpacing
        sv.axis = NSLayoutConstraint.Axis.vertical
        return sv
    }()
    
    open var middleStackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = UIStackView.Distribution.equalSpacing
        sv.alignment = .fill
        sv.spacing = 20.0
        sv.axis = NSLayoutConstraint.Axis.vertical
        sv.setContentHuggingPriority(.required, for: NSLayoutConstraint.Axis.vertical)
        sv.setContentCompressionResistancePriority(.required, for: NSLayoutConstraint.Axis.vertical)
        sv.height.lessThanOrEqual(to: 500)
        return sv
    }()
    
    public let layoutView: UIView = UIView()
    
    open var authButtonStackView: UIStackView?
    open var additionalActionsStackView: UIStackView?
    
    // MARK: Notifications
    override open func notificationsToObserve() -> [Notification.Name] {
        return super.notificationsToObserve() + [UIResponder.keyboardWillHideNotification, UIResponder.keyboardWillShowNotification]
    }
    
    override open func didObserve(notification: Notification) {
        super.didObserve(notification: notification)
        guard let authButtonStackView = authButtonStackView else {
            return
        }
        switch notification.name {
        case UIResponder.keyboardWillHideNotification:
            middleStackView.insertArrangedSubview(authButtonStackView, at: 0)
        case UIResponder.keyboardWillShowNotification:
            middleStackView.removeArrangedSubview(authButtonStackView, removeFromSuperview: true)
        default: break
        }
    }
    
    override open func createSubviews() {
        
        view.addSubview(layoutView)
        
        authButtonStackView = createAuthButtonStackView()
        additionalActionsStackView = createAdditionalActionsStackView()
        let optionalMiddleViews: [UIView?] = [authButtonStackView, mainAuthView]
        middleStackView.addArrangedSubviews(optionalMiddleViews.removeNils())
        let optionalViews: [UIView?] = [imageView, middleStackView, additionalActionsStackView]
        mainStackView.addArrangedSubviews(optionalViews.removeNils())
        self.layoutView.addSubview(mainStackView)
    }
    
    override open func createAutoLayoutConstraints() {
        
        let layoutViewInsets = layoutInsets()
        layoutView.horizontalEdges.equal(to: horizontalEdges.inset(layoutViewInsets.leading, layoutViewInsets.trailing))
        
        let topKeyboardConstraint = KeyboardAdjustableLayoutConstraint.createConstraint(item: layoutView,
                                                                                        attribute: .top, 
                                                                                        relatedBy: .equal, 
                                                                                        toItem: view, 
                                                                                        attribute: .top, 
                                                                                        multiplier: 1.0, 
                                                                                        keyboardHiddenConstant: layoutViewInsets.top, 
                                                                                        keyboardVisibleConstant: UIApplication.shared.statusBarFrame.h)
        
        let bottomKeyboardConstraint =  KeyboardDodgingLayoutConstraint.createConstraint(item: layoutView,
                                                                                         attribute: .bottom,
                                                                                         relatedBy: .equal,
                                                                                         toItem: view,
                                                                                         attribute: .bottom,
                                                                                         multiplier: 1.0,
                                                                                         keyboardHiddenConstant: -layoutViewInsets.bottom)
        
        imageView.height.lessThanOrEqual(to: layoutView.width.times(0.5))
        imageView.width.equal(to: imageView.height)

        [middleStackView, additionalActionsStackView].removeNils().width.equal(to: mainStackView.width)
        mainStackView.pinToSuperview()
        view.addActiveConstraints([topKeyboardConstraint, bottomKeyboardConstraint])
        
    }

    override open func style() {
        super.style()
        view.backgroundColor = .primary
        layoutView.backgroundColor = UIColor.clear
    }

    open func layoutInsets() -> LayoutPadding {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return iPadLayoutInsets()
        default: return iPhoneLayoutInsets()
        }
    }
    
    open func iPadLayoutInsets() -> LayoutPadding {
        let sidePadding = view.frame.h * 0.4
        let bottomPadding = view.frame.h * 0.2
        let topPadding = view.frame.h * 0.25
        return LayoutPadding(top: topPadding, leading: sidePadding, bottom: bottomPadding, trailing: sidePadding)
    }
    
    open func iPhoneLayoutInsets() -> LayoutPadding {
        let sidePadding: CGFloat = 50.0
        let bottomPadding: CGFloat = 50.0
        let topPadding: CGFloat = 50.0
        return LayoutPadding(top: topPadding, leading: sidePadding, bottom: bottomPadding, trailing: sidePadding)
    }
    
    func createAuthButtonStackView() -> UIStackView? {
        guard let authButtons = authButtons else {
            return nil
        }
        let stackView = UIStackView(arrangedSubviews: authButtons)
        stackView.alignment = UIStackView.Alignment.fill
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.height.equal(to: 45.0)
        
        return stackView
    }
    
    open func createAdditionalActionsStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: stackedAdditionalActionsViews())
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 45.0
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        return stackView
    }
    
    open func stackedAdditionalActionsViews() -> [UIView] {
        return []
    }

    // MARK: AuthControllerDelegate

	open override func showAuthViews(animated: Bool = true) {
		super.showAuthViews(animated: animated)
		showBottomStacks(animated: animated)
	}

	open override func hideAuthViews(animated: Bool = true) {
		super.hideAuthViews()
		hideBottomStacks(animated: animated)
	}

	open override func stopAuthenticationInProgressAnimation() {
		super.stopAuthenticationInProgressAnimation()
		imageView.stopInfiniteFadeInOut(1.0)
	}

	open override func startAuthenticationInProgressAnimation() {
		super.startAuthenticationInProgressAnimation()
		imageView.startInfiniteFadeInOut()
	}
    
    // MARK: Convenience
    open var bottomStacks: [UIStackView] {
        return [middleStackView, additionalActionsStackView].removeNils()
    }
    
    let stackVisibilityAnimationDuration: Double = 0.3
    open func showBottomStacks(animated: Bool = true) {
        animateStackedViews(bottomStacks, hidden: false, animated: animated)
    }
    
    open func hideBottomStacks(animated: Bool = true) {
        animateStackedViews(bottomStacks, hidden: true, animated: animated)
    }
    
    open func animateStackedViews(_ views: [UIView], hidden: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? stackVisibilityAnimationDuration : 0.0, animations: {
            views.forEach {$0.alpha = hidden ? 0 : 1}
            //views.forEach{$0.hidden = hidden}
        })
    }
}
