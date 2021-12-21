//
//  InfinityScroller.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

public protocol CustomInfiniteScrollAnimator {
    func animateState(_ state: InfiniteScrollState)
}

public enum InfiniteScrollState: Equatable, CustomStringConvertible {
    case none
    case loading

    public var description: String {
        switch self {
        case .none: return "None"
        case .loading: return "Loading"
        }
    }
}

public func == (left: InfiniteScrollState, right: InfiniteScrollState) -> Bool {
    switch (left, right) {
    case (.none, .none): return true
    case (.loading, .loading): return true
    default:
        return false
    }
}

class InfiniteScroller: NSObject {
    weak var scrollView: UIScrollView? {
        willSet {
            self.removeScrollViewObserving(self.scrollView)
            self.containerView.removeFromSuperview()
        }
        didSet {
            self.addScrollViewObserving(self.scrollView)
            if let scrollView = scrollView {
                switch self.direction {
                case .vertical:
                    scrollView.contentInset.bottom += self.defaultDistanceToTrigger
                case .horizontal:
                    scrollView.contentInset.right += self.defaultDistanceToTrigger
                }
                if #available(iOS 11.0, *) {
                    defaultContentInset = scrollView.adjustedContentInset
                } else {
                    self.defaultContentInset = scrollView.contentInset
                }

                scrollView.addSubview(self.containerView)
                self.adjustFooterFrame()
            }
        }
    }

    var animator: CustomInfiniteScrollAnimator
    var containerView: FooterContainerView
    var direction: ScrollDirection
    var action: (() -> Void)?
    var enable = true

    var defaultContentInset = UIEdgeInsets.zero
    var defaultDistanceToTrigger: CGFloat = 0.0

    var stickToContent = true {
        didSet {
            self.adjustFooterFrame()
        }
    }

    init(height: CGFloat, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator) {
        self.defaultDistanceToTrigger = height
        self.animator = animator
        self.containerView = FooterContainerView()
        self.direction = direction
    }

    // MARK: - Observe Scroll View

    var KVOContext = "InfinityScrollKVOContext"
    func addScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &self.KVOContext)
        scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: &self.KVOContext)
        scrollView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: &self.KVOContext)
    }

    func removeScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &self.KVOContext)
        scrollView?.removeObserver(self, forKeyPath: "contentInset", context: &self.KVOContext)
        scrollView?.removeObserver(self, forKeyPath: "contentSize", context: &self.KVOContext)
    }

    fileprivate var lastOffset = CGPoint()

    // swiftlint:disable:next block_based_kvo cyclomatic_complexity
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.KVOContext {
            if keyPath == "contentSize" {
                self.adjustFooterFrame()
            } else if keyPath == "contentInset" {
                guard !self.scrollView!.lockInset else {
                    return
                }
                self.defaultContentInset = (change![.newKey]! as AnyObject).uiEdgeInsetsValue!
                self.adjustFooterFrame()
            } else if keyPath == "contentOffset" {
                let point = (change![.newKey]! as AnyObject).cgPointValue!

                if self.direction == .vertical {
                    guard self.lastOffset.y != point.y else {
                        return
                    }
                } else {
                    guard self.lastOffset.x != point.x else {
                        return
                    }
                }
                guard !self.updatingState, self.enable else {
                    return
                }

                var distance: CGFloat = 0

                switch (self.direction, self.stickToContent) {
                case (.vertical, true):
                    distance = self.scrollView!.contentSize.height - point.y - self.scrollView!.frame.height
                case (.vertical, false):
                    distance = self.scrollView!.contentSize.height + self.defaultContentInset.bottom - point.y - self.scrollView!.frame.height
                case (.horizontal, true):
                    distance = self.scrollView!.contentSize.width - point.x - self.scrollView!.frame.width
                case (.horizontal, false):
                    distance = self.scrollView!.contentSize.width + self.defaultContentInset.right - point.x - self.scrollView!.frame.width
                }

                // 要保证scrollView里面是有内容的, 且保证是在上滑
                if self.state != .loading {
                    let verticalShouldLoad: Bool = distance < 0 && self.scrollView!.contentSize.height > 0 && point.y > self.lastOffset.y
                    let horizontalShouldLoad: Bool = distance < 0 && self.scrollView!.contentSize.width > 0 && point.x > self.lastOffset.x
                    let shouldLoad: Bool = self.direction == .vertical ? verticalShouldLoad : horizontalShouldLoad
                    if shouldLoad {
                        self.state = .loading
                    }
                }

                self.lastOffset = point
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    var lockInset = false
    var updatingState = false
    var state: InfiniteScrollState = .none {
        didSet {
            self.animator.animateState(self.state)
            DispatchQueue.main.async {
                switch self.state {
                case .loading where oldValue == .none:

                    self.updatingState = true
                    var inset: UIEdgeInsets!
                    if self.direction == .vertical {
                        let jumpToBottom = self.defaultDistanceToTrigger + self.defaultContentInset.bottom
                        inset = UIEdgeInsets(top: self.defaultContentInset.top, left: self.defaultContentInset.left, bottom: jumpToBottom, right: self.defaultContentInset.right)
                    } else {
                        let jumpToBottom = self.defaultDistanceToTrigger + self.defaultContentInset.right
                        inset = UIEdgeInsets(top: self.defaultContentInset.top, left: self.defaultContentInset.left, bottom: self.defaultContentInset.bottom, right: jumpToBottom)
                    }

                    self.scrollView?.setContentInset(inset, completion: { [unowned self] _ in
                        self.updatingState = false
                    })
                    self.action?()
                case .none where oldValue == .loading:
                    self.updatingState = true
                    self.scrollView?.setContentInset(self.defaultContentInset, completion: { _ in
                        self.updatingState = false
                    })
                default:
                    break
                }
            }
        }
    }

    func adjustFooterFrame() {
        if let scrollView = scrollView {
            self.containerView.frame = self.containerFrame(scrollView: scrollView)
        }
    }

    func containerFrame(scrollView: UIScrollView) -> CGRect {
        switch (self.direction, self.stickToContent) {
        case (.vertical, true):
            return CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: self.defaultDistanceToTrigger)
        case (.vertical, false):
            return CGRect(x: 0, y: scrollView.contentSize.height + self.defaultContentInset.bottom, width: scrollView.bounds.width, height: self.defaultDistanceToTrigger)
        case (.horizontal, true):
            return CGRect(x: scrollView.contentSize.width, y: 0, width: self.defaultDistanceToTrigger, height: scrollView.bounds.height)
        case (.horizontal, false):
            return CGRect(x: scrollView.contentSize.width + self.defaultContentInset.right, y: 0, width: self.defaultDistanceToTrigger, height: scrollView.bounds.height)
        }
    }

    // MARK: - Infinity Scroll

    func beginInfiniteScrolling() {
        if self.direction == .vertical {
            self.scrollView?.setContentOffset(CGPoint(x: 0,
                                                      y: self.scrollView!.contentSize.height + self.defaultContentInset.bottom - self.scrollView!.frame.height + self.defaultDistanceToTrigger),
                                              animated: true)
        } else {
            self.scrollView?.setContentOffset(CGPoint(x: self.scrollView!.contentSize.width + self.defaultContentInset.right - self.scrollView!.frame.width + self.defaultDistanceToTrigger,
                                                      y: 0),
                                              animated: true)
        }
    }

    func endInfiniteScrolling() {
        self.state = .none
    }
}

class FooterContainerView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            view.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
}
