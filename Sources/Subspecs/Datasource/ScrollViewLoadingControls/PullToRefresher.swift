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
        let horizontalFrame = CGRect(x: -distanceToTrigger + animatorOffset.horizontal,
                                     y: animatorOffset.vertical,
                                     width: distanceToTrigger,
                                     height: scrollView.frame.height)
        let verticalFrame = CGRect(x: 0 + animatorOffset.horizontal,
                                   y: -distanceToTrigger + animatorOffset.vertical,
                                   width: scrollView.frame.width,
                                   height: distanceToTrigger)
        return direction == .horizontal ? horizontalFrame : verticalFrame
    }

    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving(scrollView)
            containerView.removeFromSuperview()
        }
        didSet {
            addScrollViewObserving(scrollView)
            if let scrollView = scrollView {
                defaultContentInset = scrollView.contentInset

                containerView.scrollView = scrollView
                scrollView.addSubview(containerView)
                let frame = containerFrame(scrollView: scrollView)
                switch direction {
                case .horizontal:
                    containerView.height.equal(to: scrollView)
                    containerView.width.equal(to: frame.w)
                    containerView.centerY.equalToSuperview()
                    containerView.trailing.equal(to: scrollView.leading)
                case .vertical:
                    containerView.width.equal(to: scrollView)
                    containerView.height.equal(to: frame.h)
                    containerView.centerX.equalToSuperview()
                    containerView.bottom.equal(to: scrollView.top)
                }
            }
        }
    }

    var animator: CustomPullToRefreshAnimator
    var containerView: HeaderContainerView
    var direction: InfinityScrollDirection
    var action: (() -> Void)?
    var enable = false

    var animatorOffset: UIOffset = UIOffset() {
        didSet {
            if let scrollView = scrollView {
                containerView.frame = containerFrame(scrollView: scrollView)
            }
        }
    }

    // Values
    var defaultContentInset: UIEdgeInsets = UIEdgeInsets()
    public var distanceToTrigger: CGFloat = 0.0
    var scrollbackImmediately = false

    init(height: CGFloat, direction: InfinityScrollDirection, animator: CustomPullToRefreshAnimator) {
        distanceToTrigger = height
        self.animator = animator
        containerView = HeaderContainerView()
        self.direction = direction
    }

    // MARK: - Observe Scroll View

    var KVOContext = "PullToRefreshKVOContext"
    func addScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &KVOContext)
        scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: &KVOContext)
    }

    func removeScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
        scrollView?.removeObserver(self, forKeyPath: "contentInset", context: &KVOContext)
    }

    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &KVOContext {
            if keyPath == "contentOffset" {
                guard !updatingState, enable else {
                    return
                }
                let point = (change![.newKey]! as AnyObject).cgPointValue!
                let topOffset = direction == .horizontal ? point.x + defaultContentInset.left : point.y + defaultContentInset.top
                switch topOffset {
                case 0 where state != .loading:
                    state = .none
                case -distanceToTrigger ... 0 where state != .loading:
                    state = .releasing(progress: min(-topOffset / distanceToTrigger, 1.0))
                case (-CGFloat.greatestFiniteMagnitude) ... (-distanceToTrigger) where state == .releasing(progress: 1):
                    if scrollView!.isDragging {
                        state = .releasing(progress: 1.0)
                    } else {
                        state = .loading
                    }
                default:
                    break
                }
            } else if keyPath == "contentInset" {
                guard !scrollView!.lockInset else {
                    return
                }
                defaultContentInset = (change![.newKey]! as AnyObject).uiEdgeInsetsValue!
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
        let verticalContentOffset = CGPoint(x: 0, y: -(distanceToTrigger + defaultContentInset.top + 10))
        let horizontalContentOffset = CGPoint(x: -(distanceToTrigger + defaultContentInset.left + 10), y: 0)
        scrollView?.setContentOffset(direction == .horizontal ? horizontalContentOffset : verticalContentOffset, animated: true)
    }

    func endRefreshing() {
        state = .none
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

        firstResponderViewController()?.automaticallyAdjustsScrollViewInsets = false
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
