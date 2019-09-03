//
//  ScrollViewHeaderBehavior.swift
//  Pods
//
//  Created by Brian Strobach on 4/25/17.
//
//

import Foundation
import UIKit

public enum ScrollViewHeaderBehaviorType {
    case parallax(strength: CGFloat)
    case stretch(strength: CGFloat)
    case fade
    case blur(timing: ScrollViewHeaderBehaviorTiming)
}

open class ScrollViewHeaderBehavior {
    public init() {}

    public weak var scrollViewHeader: ScrollViewHeader! {
        didSet {
            setup()
        }
    }

    open func adjustViews(for scrollViewHeader: ScrollViewHeader) {

    }

    open func setup() {}
}

public enum ScrollViewHeaderBehaviorTiming {
    case onPull, onCollapse
}

@available(iOS 10.0, *)
open class PercentDrivenAnimationScrollViewHeaderBehavior: ScrollViewHeaderBehavior {
    open var timing: [ScrollViewHeaderBehaviorTiming]
    open var strength: CGFloat
    open lazy var animator: UIViewPropertyAnimator = createViewPropertyAnimator()
    public init(timing: [ScrollViewHeaderBehaviorTiming] = [.onCollapse], strength: CGFloat = 1.0) {
        self.strength = strength
        self.timing = timing
        super.init()
    }

    deinit {
        animator.stopAnimation(true)
    }

    open func createViewPropertyAnimator() -> UIViewPropertyAnimator {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return UIViewPropertyAnimator()
    }

    open override func adjustViews(for scrollViewHeader: ScrollViewHeader) {
        super.adjustViews(for: scrollViewHeader)
        switch scrollViewHeader.headerState {
        case .expanded:
            animator.fractionComplete = 0.0
        case .transitioning, .collapsed:
            animator.fractionComplete = timing.contains(.onCollapse) ? scrollViewHeader.percentCollapsed * strength : 0.0
        case .stretched:
            animator.fractionComplete = timing.contains(.onPull) ? (scrollViewHeader.percentExpanded - 1.0) * strength : 0.0
        }
    }
}

open class ScrollViewHeaderPinBehavior: ScrollViewHeaderBehavior {
    open override func setup() {
        super.setup()
    }

    open override func adjustViews(for scrollViewHeader: ScrollViewHeader) {
        super.adjustViews(for: scrollViewHeader)
        scrollViewHeader.scrollView.bringSubviewToFront(scrollViewHeader)
//        var topConstant = -scrollView.contentInset.top
//        if(visibleHeaderHeight <= collapsedHeaderHeight){
//            topConstant = scrollView.contentOffset.y + collapsedHeaderHeight - expandedHeight
//        }
//        viewConstraints[.top]?.constant = topConstant
        scrollViewHeader.backgroundViewConstraints[.top]?.first?.constant = scrollViewHeader.offset
    }
}

open class ScrollViewHeaderParallaxBehavior: ScrollViewHeaderBehavior {
    open var speed: CGFloat

    open var parallaxOffset: CGFloat {
        return speed * scrollViewHeader.percentCollapsed * scrollViewHeader.expandedHeight
    }

    public init(speed: CGFloat = 0.3) {
        assert(0.0 ... 1.0 ~= speed, "Parallax strength can only be between 0.0 and 1.0 inclusive")
        self.speed = speed
    }

    open override func setup() {}

    open override func adjustViews(for scrollViewHeader: ScrollViewHeader) {
        super.adjustViews(for: scrollViewHeader)
        scrollViewHeader.backgroundViewConstraints[.centerY]?.first?.constant = parallaxOffset
        switch scrollViewHeader.headerState {
        case .collapsed, .transitioning:
            scrollViewHeader.resetBackgroundViewSizeConstraints()
        case .expanded, .stretched:
            break
            // scrollViewHeader.backgroundViewConstraints[.width]?.constant = scrollViewHeader.offset
        }
    }
}

@available(iOS 10.0, *)
open class ScrollViewVisualEffectBehavior: PercentDrivenAnimationScrollViewHeaderBehavior {
    open var visualEffectView: UIVisualEffectView
    open var visualEffect: UIVisualEffect

    open override func setup() {
        super.setup()
        scrollViewHeader.headerLayoutView.insertSubview(visualEffectView, aboveSubview: scrollViewHeader.headerBackgroundImageView)
        visualEffectView.pinToSuperview()
    }

    public init(timing: [ScrollViewHeaderBehaviorTiming] = [.onCollapse], strength: CGFloat = 1.0, visualEffect: UIVisualEffect = UIBlurEffect(style: .dark)) {
        self.visualEffect = visualEffect
        visualEffectView = UIVisualEffectView()
        super.init(timing: timing, strength: strength)
    }

    open override func createViewPropertyAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.visualEffectView.effect = sSelf.visualEffect
        }
    }
}

open class ScrollViewHeaderStretchBehavior: ScrollViewHeaderBehavior {
    open override func adjustViews(for scrollViewHeader: ScrollViewHeader) {
        scrollViewHeader.headerLayoutHeightConstraint?.constant = max(scrollViewHeader.expandedHeaderHeight, scrollViewHeader.expandedHeaderHeight - scrollViewHeader.offset)
        switch scrollViewHeader.headerState {
        case .expanded, .stretched:
            scrollViewHeader.viewConstraints[.top]?.first?.constant = scrollViewHeader.offset - scrollViewHeader.scrollView.contentInset.top
        default: break
        }
    }
}

@available(iOS 10.0, *)
open class ScrollViewHeaderFadeBehavior: PercentDrivenAnimationScrollViewHeaderBehavior {
    open override func createViewPropertyAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.scrollViewHeader.alpha = 0.0
        }
    }
}

@available(iOS 10.0, *)
open class ScrollViewHeaderFillColorBehavior: PercentDrivenAnimationScrollViewHeaderBehavior {
    var fillColor: UIColor
    var fillView: UIView = UIView()

    open override func setup() {
        super.setup()

        if !scrollViewHeader.subheaderCollapses {
            scrollViewHeader.insertSubview(fillView, belowSubview: scrollViewHeader.subheaderBackgroundView)
        }
        else {
            scrollViewHeader.insertSubview(fillView, aboveSubview: scrollViewHeader.headerBackgroundImageView)
        }
        fillView.pinToSuperview()
        fillView.backgroundColor = fillColor
        fillView.alpha = 0.0
    }

    public init(timing: [ScrollViewHeaderBehaviorTiming] = [.onCollapse], strength: CGFloat = 1.0, fillColor: UIColor) {
        self.fillColor = fillColor
        super.init(timing: timing, strength: strength)
    }

    open override func createViewPropertyAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.fillView.alpha = 1.0
        }
    }
}
