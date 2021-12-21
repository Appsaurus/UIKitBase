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
    public static let defaultInfiniteScrollAnimator: () -> CustomInfiniteScrollAnimator = { CircleInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30)) }
    public static let defaultPullToRefreshAnimator: () -> CustomPullToRefreshAnimator = { DefaultRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24)) }

    public let pullToRefresh: PullToRefreshWrapper
    public let infiniteScroll: InfiniteScrollWrapper
    let scrollView: UIScrollView

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.pullToRefresh = PullToRefreshWrapper(scrollView: scrollView)
        self.infiniteScroll = InfiniteScrollWrapper(scrollView: scrollView)
    }

    public class PullToRefreshWrapper {
        let scrollView: UIScrollView
        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func add(height: CGFloat = 60, direction: ScrollDirection, animator: CustomPullToRefreshAnimator = defaultPullToRefreshAnimator(), action: (() -> Void)?) {
            self.scrollView.addPullToRefresh(height, direction: direction, animator: animator, action: action)
        }

        public func bind(height: CGFloat = 60, direction: ScrollDirection, animator: CustomPullToRefreshAnimator = defaultPullToRefreshAnimator(), action: (() -> Void)?) {
            self.scrollView.bindPullToRefresh(height, direction: direction, toAnimator: animator, action: action)
        }

        public func remove() {
            self.scrollView.removePullToRefresh()
        }

        public func begin() {
            self.scrollView.beginRefreshing()
        }

        public func end() {
            self.scrollView.endRefreshing()
        }

        public var isEnabled: Bool {
            get {
                return self.scrollView.isPullToRefreshEnabled
            }
            set {
                self.scrollView.isPullToRefreshEnabled = newValue
            }
        }

        public var isScrollingToTopImmediately: Bool {
            get {
                return self.scrollView.isScrollingToTopImmediately
            }
            set {
                self.scrollView.isScrollingToTopImmediately = newValue
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
                self.scrollView.pullToRefresher?.animatorOffset = newValue
            }
        }

        public var distanceToTrigger: CGFloat {
            get {
                return self.scrollView.pullToRefresher?.distanceToTrigger ?? 0
            }
            set {
                self.scrollView.pullToRefresher?.distanceToTrigger = newValue
            }
        }
    }

    public class InfiniteScrollWrapper {
        let scrollView: UIScrollView
        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func add(height: CGFloat = 60, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
            self.scrollView.addInfiniteScroll(height, direction: direction, animator: animator, action: action)
        }

        public func bind(height: CGFloat = 60, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
            self.scrollView.bindInfiniteScroll(height, direction: direction, toAnimator: animator, action: action)
        }

        public func remove() {
            self.scrollView.removeInfiniteScroll()
        }

        public func begin() {
            self.scrollView.beginInfiniteScrolling()
        }

        public func end() {
            self.scrollView.endInfiniteScrolling()
        }

        public var isEnabled: Bool {
            get {
                return self.scrollView.isInfiniteScrollEnabled
            }
            set {
                self.scrollView.isInfiniteScrollEnabled = newValue
            }
        }

        public var isStickToContent: Bool {
            get {
                return self.scrollView.isInfiniteStickToContent
            }
            set {
                self.scrollView.isInfiniteStickToContent = newValue
            }
        }
    }

    public func clear() {
        self.pullToRefresh.remove()
        self.infiniteScroll.remove()
    }
}

extension UIScrollView {
    func addPullToRefresh(_ height: CGFloat = 60.0, direction: ScrollDirection, animator: CustomPullToRefreshAnimator, action: (() -> Void)?) {
        self.bindPullToRefresh(height, direction: direction, toAnimator: animator, action: action)

        if let animatorView = animator as? UIView {
            self.pullToRefresher?.containerView.addSubview(animatorView)
        }
    }

    func bindPullToRefresh(_ height: CGFloat = 60.0, direction: ScrollDirection, toAnimator: CustomPullToRefreshAnimator, action: (() -> Void)?) {
        self.removePullToRefresh()

        self.pullToRefresher = PullToRefresher(height: height, direction: direction, animator: toAnimator)
        self.pullToRefresher?.scrollView = self
        self.pullToRefresher?.action = action
    }

    func removePullToRefresh() {
        self.pullToRefresher?.scrollView = nil
        self.pullToRefresher = nil
    }

    func beginRefreshing() {
        self.pullToRefresher?.beginRefreshing()
    }

    func endRefreshing() {
        self.pullToRefresher?.endRefreshing()
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
            return self.pullToRefresher?.enable ?? false
        }
        set {
            self.pullToRefresher?.enable = newValue
        }
    }

    var isScrollingToTopImmediately: Bool {
        get {
            return self.pullToRefresher?.scrollbackImmediately ?? false
        }
        set {
            self.pullToRefresher?.scrollbackImmediately = newValue
        }
    }
}

// MARK: - InfiniteScroll

extension UIScrollView {
    func addInfiniteScroll(_ height: CGFloat = 80.0, direction: ScrollDirection, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        self.bindInfiniteScroll(height, direction: direction, toAnimator: animator, action: action)

        if let animatorView = animator as? UIView {
            self.infiniteScroller?.containerView.addSubview(animatorView)
        }
    }

    func bindInfiniteScroll(_ height: CGFloat = 80.0, direction: ScrollDirection, toAnimator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        self.removeInfiniteScroll()

        self.infiniteScroller = InfiniteScroller(height: height, direction: direction, animator: toAnimator)
        self.infiniteScroller?.scrollView = self
        self.infiniteScroller?.action = action
    }

    func removeInfiniteScroll() {
        self.infiniteScroller?.scrollView = nil
        self.infiniteScroller = nil
    }

    func beginInfiniteScrolling() {
        self.infiniteScroller?.beginInfiniteScrolling()
    }

    func endInfiniteScrolling() {
        self.infiniteScroller?.endInfiniteScrolling()
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
            return self.infiniteScroller?.stickToContent ?? false
        }
        set {
            self.infiniteScroller?.stickToContent = newValue
        }
    }

    var isInfiniteScrollEnabled: Bool {
        get {
            return self.infiniteScroller?.enable ?? false
        }
        set {
            self.infiniteScroller?.enable = newValue
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
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () in

            self.lockInset = true
            self.contentInset = inset
            self.lockInset = false

        }, completion: { finished in

            completion?(finished)
        })
    }
}
