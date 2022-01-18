//
//  TabBarChildViewControllerProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 1/15/17.
//
//

import Foundation
import Swiftest
import UIKit

public protocol Refreshable {
    func refresh()
}

public extension Refreshable where Self: PaginationManaged & ScrollViewReferencing {
    func refresh() {
        if paginationConfig.refreshable {
            scrollView.beginRefreshing()
        }
    }
}

public protocol TabBarChild {
    // Must be called by TabBarController at proper times
    func tabBarChildDidAppear()
    func tabItemWasTappedWhileActive()
    func defaultTabItemWasTappedWhileActive()
}

public extension TabBarChild {
    func tabItemWasTappedWhileActive() {
        defaultTabItemWasTappedWhileActive()
    }
}

// Forwards protocol calls to vc at end of navigation stack by default
public extension TabBarChild where Self: UINavigationController {
    private var stackedChild: TabBarChild? {
        return viewControllers.last as? TabBarChild
    }

    func defaultTabItemWasTappedWhileActive() {
        self.stackedChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        self.stackedChild?.tabBarChildDidAppear()
    }
}

// Scroll to top, then reload by default
public extension TabBarChild where Self: ScrollViewReferencing {
    func defaultTabItemWasTappedWhileActive() {
        guard scrollView.hasReachedTopOfContent else {
            scrollView.scrollToTop()
            return
        }

        (self as? Refreshable)?.refresh()
    }

    func tabBarChildDidAppear() {}
}

// Forwards protocol calls to paged vc by default
public extension TabBarChild where Self: BaseParentPagingViewController {
    private var pagedChild: TabBarChild? {
        return currentPagedViewController as? TabBarChild
    }

    func defaultTabItemWasTappedWhileActive() {
        self.pagedChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        self.pagedChild?.tabBarChildDidAppear()
    }
}

public extension TabBarChild where Self: BaseScrollviewParentViewController {
    private var contentChild: TabBarChild? {
        return children.first as? TabBarChild
    }

    func defaultTabItemWasTappedWhileActive() {
        guard scrollView.hasReachedTopOfContent else {
            scrollView.scrollToTop()
            return
        }
        self.contentChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        self.contentChild?.tabBarChildDidAppear()
    }
}

public extension TabBarChild where Self: BaseParentViewController {
    private var contentChild: TabBarChild? {
        return children.first as? TabBarChild
    }

    func defaultTabItemWasTappedWhileActive() {
        self.contentChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        self.contentChild?.tabBarChildDidAppear()
    }
}
