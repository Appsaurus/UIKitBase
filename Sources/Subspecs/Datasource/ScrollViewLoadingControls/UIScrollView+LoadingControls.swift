//
//  UIScrollView+Infinity.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import DarkMagic
import Swiftest
import UIKit

private var associatedPullToRefresherKey: String = "InfinityPullToRefresherKey"
private var associatedInfiniteScrollerKey: String = "InfinityInfiniteScrollerKey"

private var associatedisPullToRefreshEnabledKey: String = "InfinityisPullToRefreshEnabledKey"
private var associatedisInfiniteScrollEnabledKey: String = "InfinityisInfiniteScrollEnabledKey"

// MARK: - PullToRefresh

private extension AssociatedObjectKeys {
    static let loadingControls = AssociatedObjectKey<ScrollViewLoadingControl>("loadingControls")
}

public extension UIScrollView {
    var loadingControls: ScrollViewLoadingControl {
        get {
            return self[.loadingControls, ScrollViewLoadingControl(scrollView: self)]
        }
        set {
            self[.loadingControls] = newValue
        }
    }
}

public enum ScrollDirection {
    case vertical, horizontal
}

public class ScrollViewLoadingControl {
    public static let defaultInfiniteScrollAnimator: () -> CustomInfiniteScrollAnimator = { return CircleInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) }
    public static let defaultPullToRefreshAnimator: () -> CustomPullToRefreshAnimator = { return DefaultRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24)) }

    public let pullToRefresh: PullToRefreshWrapper
    public let infiniteScroll: InfiniteScrollWrapper
    let scrollView: UIScrollView

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        pullToRefresh = PullToRefreshWrapper(scrollView: scrollView)
        infiniteScroll = InfiniteScrollWrapper(scrollView: scrollView)
    }

    public class PullToRefreshWrapper {
        let scrollView: UIScrollView
        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func add(height: CGFloat = 60, direction: ScrollDirection, animator: CustomPullToRefreshAnimator = defaultPullToRefreshAnimator(), action: (() -> Void)?) {
            scrollView.addPullToRefresh(height, direction: direction, animator: animator, action: action)
        }

        public func bind(height: CGFloat = 60, direction: ScrollDirection, animator: CustomPullToRefreshAnimator = defaultPullToRefreshAnimator(), action: (() -> Void)?) {
            scrollView.bindPullToRefresh(height, direction: direction, toAnimator: animator, action: action)
        }

        public func remove() {
            scrollView.removePullToRefresh()
        }

        public func begin() {
            scrollView.beginRefreshing()
        }

        public func end() {
            scrollView.endRefreshing()
        }

        public var isEnabled: Bool {
            get {
                return scrollView.isPullToRefreshEnabled
            }
            set {
                scrollView.isPullToRefreshEnabled = newValue
            }
        }

        public var isScrollingToTopImmediately: Bool {
            get {
                return scrollView.isScrollingToTopImmediately
            }
            set {
                scrollView.isScrollingToTopImmediately = newValue
            }
        }

        public var animatorOffset: UIOffset {
            get {
                if let offset = scrollView.pullToRefresher?.animatorOffset {
                    return offset
                }
                return UIOffset()
            }
            set {
                scrollView.pullToRefresher?.animatorOffset = newValue
            }
        }

        public var distanceToTrigger: CGFloat {
            get {
                return scrollView.pullToRefresher?.distanceToTrigger ?? 0
            }
            set {
                scrollView.pullToRefresher?.distanceToTrigger = newValue
            }
        }
    }

    public class InfiniteScrollWrapper {
        let scrollView: UIScrollView
        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func add(height: CGFloat = 60, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
            scrollView.addInfiniteScroll(height, direction: direction, animator: animator, action: action)
        }

        public func bind(height: CGFloat = 60, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
            scrollView.bindInfiniteScroll(height, direction: direction, toAnimator: animator, action: action)
        }

        public func remove() {
            scrollView.removeInfiniteScroll()
        }

        public func begin() {
            scrollView.beginInfiniteScrolling()
        }

        public func end() {
            scrollView.endInfiniteScrolling()
        }

        public var isEnabled: Bool {
            get {
                return scrollView.isInfiniteScrollEnabled
            }
            set {
                scrollView.isInfiniteScrollEnabled = newValue
            }
        }

        public var isStickToContent: Bool {
            get {
                return scrollView.isInfiniteStickToContent
            }
            set {
                scrollView.isInfiniteStickToContent = newValue
            }
        }
    }

    public func clear() {
        pullToRefresh.remove()
        infiniteScroll.remove()
    }
}

extension UIScrollView {
    func addPullToRefresh(_ height: CGFloat = 60.0, direction: ScrollDirection, animator: CustomPullToRefreshAnimator, action: (() -> Void)?) {
        bindPullToRefresh(height, direction: direction, toAnimator: animator, action: action)

        if let animatorView = animator as? UIView {
            pullToRefresher?.containerView.addSubview(animatorView)
        }
    }

    func bindPullToRefresh(_ height: CGFloat = 60.0, direction: ScrollDirection, toAnimator: CustomPullToRefreshAnimator, action: (() -> Void)?) {
        removePullToRefresh()

        pullToRefresher = PullToRefresher(height: height, direction: direction, animator: toAnimator)
        pullToRefresher?.scrollView = self
        pullToRefresher?.action = action
    }

    func removePullToRefresh() {
        pullToRefresher?.scrollView = nil
        pullToRefresher = nil
    }

    func beginRefreshing() {
        pullToRefresher?.beginRefreshing()
    }

    func endRefreshing() {
        pullToRefresher?.endRefreshing()
    }

    // MARK: - Properties

    var pullToRefresher: PullToRefresher? {
        get {
            return objc_getAssociatedObject(self, &associatedPullToRefresherKey) as? PullToRefresher
        }
        set {
            objc_setAssociatedObject(self, &associatedPullToRefresherKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var isPullToRefreshEnabled: Bool {
        get {
            return pullToRefresher?.enable ?? false
        }
        set {
            pullToRefresher?.enable = newValue
        }
    }

    var isScrollingToTopImmediately: Bool {
        get {
            return pullToRefresher?.scrollbackImmediately ?? false
        }
        set {
            pullToRefresher?.scrollbackImmediately = newValue
        }
    }
}

// MARK: - InfiniteScroll

extension UIScrollView {
    func addInfiniteScroll(_ height: CGFloat = 80.0, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        bindInfiniteScroll(height, direction: direction, toAnimator: animator, action: action)

        if let animatorView = animator as? UIView {
            infiniteScroller?.containerView.addSubview(animatorView)
        }
    }

    func bindInfiniteScroll(_ height: CGFloat = 80.0, direction: ScrollDirection, toAnimator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        removeInfiniteScroll()

        infiniteScroller = InfiniteScroller(height: height, direction: direction, animator: toAnimator)
        infiniteScroller?.scrollView = self
        infiniteScroller?.action = action
    }

    func removeInfiniteScroll() {
        infiniteScroller?.scrollView = nil
        infiniteScroller = nil
    }

    func beginInfiniteScrolling() {
        infiniteScroller?.beginInfiniteScrolling()
    }

    func endInfiniteScrolling() {
        infiniteScroller?.endInfiniteScrolling()
    }

    // MARK: - Properties

    var infiniteScroller: InfiniteScroller? {
        get {
            return objc_getAssociatedObject(self, &associatedInfiniteScrollerKey) as? InfiniteScroller
        }
        set {
            objc_setAssociatedObject(self, &associatedInfiniteScrollerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var isInfiniteStickToContent: Bool {
        get {
            return infiniteScroller?.stickToContent ?? false
        }
        set {
            infiniteScroller?.stickToContent = newValue
        }
    }

    var isInfiniteScrollEnabled: Bool {
        get {
            return infiniteScroller?.enable ?? false
        }
        set {
            infiniteScroller?.enable = newValue
        }
    }
}

private var associatedSupportSpringBouncesKey: String = "InfinitySupportSpringBouncesKey"
private var associatedLockInsetKey: String = "InfinityLockInsetKey"

extension UIScrollView {
    var lockInset: Bool {
        get {
            let locked = objc_getAssociatedObject(self, &associatedLockInsetKey) as? Bool
            if locked == nil {
                return false
            }
            return locked!
        }
        set {
            objc_setAssociatedObject(self, &associatedLockInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setContentInset(_ inset: UIEdgeInsets, completion: ((Bool) -> Void)?) {
        guard contentInset != inset else {
            completion?(true)
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in

            self.lockInset = true
            self.contentInset = inset
            self.lockInset = false

        }, completion: { (finished) -> Void in

            completion?(finished)
        })
    }
}
