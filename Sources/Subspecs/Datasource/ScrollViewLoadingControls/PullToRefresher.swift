//
//  PullToRefresher.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

public protocol CustomPullToRefreshAnimator {
    func animateState(_ state: PullToRefreshState)
}

public enum PullToRefreshState: Equatable, CustomStringConvertible {
    case none
    case releasing(progress: CGFloat)
    case loading

    public var description: String {
        switch self {
        case .none: return "None"
        case let .releasing(progress): return "Releasing: \(progress)"
        case .loading: return "Loading"
        }
    }
}

public func == (left: PullToRefreshState, right: PullToRefreshState) -> Bool {
    switch (left, right) {
    case (.none, .none): return true
    case (.releasing, .releasing): return true
    case (.loading, .loading): return true
    default:
        return false
    }
}

class PullToRefresher: NSObject {
    func containerFrame(scrollView: UIScrollView) -> CGRect {
        let horizontalFrame = CGRect(x: -self.distanceToTrigger + self.animatorOffset.horizontal,
                                     y: self.animatorOffset.vertical,
                                     width: self.distanceToTrigger,
                                     height: scrollView.frame.height)
        let verticalFrame = CGRect(x: 0 + self.animatorOffset.horizontal,
                                   y: -self.distanceToTrigger + self.animatorOffset.vertical,
                                   width: scrollView.frame.width,
                                   height: self.distanceToTrigger)
        return self.direction == .horizontal ? horizontalFrame : verticalFrame
    }

    weak var scrollView: UIScrollView? {
        willSet {
            self.removeScrollViewObserving(self.scrollView)
            self.containerView.removeFromSuperview()
        }
        didSet {
            self.addScrollViewObserving(self.scrollView)
            if let scrollView = scrollView {
                self.defaultContentInset = scrollView.contentInset

                self.containerView.scrollView = scrollView
                scrollView.addSubview(self.containerView)
                let frame = self.containerFrame(scrollView: scrollView)
                switch self.direction {
                case .horizontal:
                    self.containerView.height.equal(to: scrollView)
                    self.containerView.width.equal(to: frame.w)
                    self.containerView.centerY.equalToSuperview()
                    self.containerView.trailing.equal(to: scrollView.leading)
                case .vertical:
                    self.containerView.width.equal(to: scrollView)
                    self.containerView.height.equal(to: frame.h)
                    self.containerView.centerX.equalToSuperview()
                    self.containerView.bottom.equal(to: scrollView.top)
                }
            }
        }
    }

    var animator: CustomPullToRefreshAnimator
    var containerView: HeaderContainerView
    var direction: ScrollDirection
    var action: (() -> Void)?
    var enable = false

    var animatorOffset: UIOffset = UIOffset() {
        didSet {
            if let scrollView = scrollView {
                self.containerView.frame = self.containerFrame(scrollView: scrollView)
            }
        }
    }

    // Values
    var defaultContentInset: UIEdgeInsets = UIEdgeInsets()
    public var distanceToTrigger: CGFloat = 0.0
    var scrollbackImmediately = false

    init(height: CGFloat, direction: ScrollDirection, animator: CustomPullToRefreshAnimator) {
        self.distanceToTrigger = height
        self.animator = animator
        self.containerView = HeaderContainerView()
        self.direction = direction
    }

    // MARK: - Observe Scroll View

    var KVOContext = "PullToRefreshKVOContext"
    func addScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &self.KVOContext)
        scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: &self.KVOContext)
    }

    func removeScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &self.KVOContext)
        scrollView?.removeObserver(self, forKeyPath: "contentInset", context: &self.KVOContext)
    }

    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.KVOContext {
            if keyPath == "contentOffset" {
                guard !self.updatingState, self.enable else {
                    return
                }
                let point = (change![.newKey]! as AnyObject).cgPointValue!
                let topOffset = self.direction == .horizontal ? point.x + self.defaultContentInset.left : point.y + self.defaultContentInset.top
                switch topOffset {
                case 0 where self.state != .loading:
                    self.state = .none
                case -self.distanceToTrigger ... 0 where self.state != .loading:
                    self.state = .releasing(progress: min(-topOffset / self.distanceToTrigger, 1.0))
                case (-CGFloat.greatestFiniteMagnitude) ... (-self.distanceToTrigger) where self.state == .releasing(progress: 1):
                    if self.scrollView!.isDragging {
                        self.state = .releasing(progress: 1.0)
                    } else {
                        self.state = .loading
                    }
                default:
                    break
                }
            } else if keyPath == "contentInset" {
                guard !self.scrollView!.lockInset else {
                    return
                }
                self.defaultContentInset = (change![.newKey]! as AnyObject).uiEdgeInsetsValue!
            }

        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    var updatingState = false
    var state: PullToRefreshState = .none {
        didSet {
            DispatchQueue.main.async {
                self.animator.animateState(self.state)
                switch self.state {
                case .none:
                    guard self.scrollView?.contentInset != self.defaultContentInset else { return }
                    if !self.scrollbackImmediately {
                        self.updatingState = true
                        self.scrollView?.setContentInset(self.defaultContentInset, completion: { [unowned self] (_) -> Void in
                            self.updatingState = false
                        })
                    }

                case .loading where oldValue != .loading:
                    if !self.scrollbackImmediately {
                        self.updatingState = true
                        var inset = self.defaultContentInset
                        if self.direction == .horizontal {
                            inset.left += self.distanceToTrigger
                        } else {
                            inset.top += self.distanceToTrigger
                        }
                        self.scrollView?.setContentInset(inset, completion: { [unowned self] (_) -> Void in
                            self.updatingState = false
                        })
                        PullToRefresherImpacter.impact()
                        self.action?()
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - Refresh

    func beginRefreshing() {
        let verticalContentOffset = CGPoint(x: 0, y: -(distanceToTrigger + self.defaultContentInset.top + 10))
        let horizontalContentOffset = CGPoint(x: -(distanceToTrigger + self.defaultContentInset.left + 10), y: 0)
        self.scrollView?.setContentOffset(self.direction == .horizontal ? horizontalContentOffset : verticalContentOffset, animated: true)
    }

    func endRefreshing() {
        self.state = .none
    }
}

class HeaderContainerView: UIView {
    var scrollView: UIScrollView?

    override func layoutSubviews() {
        super.layoutSubviews()

        for view in subviews {
            view.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        firstResponderViewController()?.manuallyManageScrollViewContentInsets()
    }
}

extension UIView {
    func firstResponderViewController() -> UIViewController? {
        var responder: UIResponder? = self as UIResponder
        while responder != nil {
            if responder!.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        return nil
    }
}

private class PullToRefresherImpacter {
    private static var impacter: AnyObject? = {
        if #available(iOS 10.0, *) {
            if NSClassFromString("UIFeedbackGenerator") != nil {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                return generator
            }
        }
        return nil
    }()

    public static func impact() {
        if #available(iOS 10.0, *) {
            if let impacter = impacter as? UIImpactFeedbackGenerator {
                impacter.impactOccurred()
            }
        }
    }
}
